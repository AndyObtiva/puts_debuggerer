require 'stringio'

module Kernel
  # Prints object with bonus info such as file name, line number and source
  # expression. Optionally prints out header and footer.
  # Lookup PutsDebuggerer attributes for more details about configuration options.
  #
  # Simply invoke global `pd` method anywhere you'd like to see line number and source code with output.
  # If the argument is a pure string, the print out is simplified by not showing duplicate source.
  #
  # Quickly locate printed lines using Find feature (e.g. CTRL+F) by looking for:
  # * \[PD\]
  # * file:line_number
  # * ruby expression.
  #
  # This gives you the added benefit of easily removing your pd statements later on from the code.
  #
  # Happy puts_debuggerering!
  #
  # Example Code:
  #
  #   # /Users/User/finance_calculator_app/pd_test.rb # line 1
  #   bug = 'beattle'                                 # line 2
  #   pd "Show me the source of the bug: #{bug}"      # line 3
  #   pd 'What line number am I?'                     # line 4
  #
  # Example Printout:
  #
  #   [PD] /Users/User/finance_calculator_app/pd_test.rb:3
  #      > pd "Show me the source of the bug: #{bug}"
  #     => "Show me the source of the bug: beattle"
  #   [PD] /Users/User/finance_calculator_app/pd_test.rb:4 "What line number am I?"
  def pd(*objects)
    options = PutsDebuggerer.determine_options(objects) || {}
    object = PutsDebuggerer.determine_object(objects)
    run_at = PutsDebuggerer.determine_run_at(options)
    printer = PutsDebuggerer.determine_printer(options)
    pd_inspect = options.delete(:pd_inspect)
    logger_formatter_decorated = PutsDebuggerer.printer.is_a?(Logger) && PutsDebuggerer.printer.formatter != PutsDebuggerer.logger_original_formatter
    logging_layouts_decorated = PutsDebuggerer.printer.is_a?(Logging::Logger) && PutsDebuggerer.printer.appenders.map(&:layout) != (PutsDebuggerer.logging_original_layouts.values)
  
    string = nil
    if PutsDebuggerer::RunDeterminer.run_pd?(object, run_at)
      __with_pd_options__(options) do |print_engine_options|
        run_number = PutsDebuggerer::RunDeterminer.run_number(object, run_at)
        formatter_pd_data = __build_pd_data__(object, print_engine_options: print_engine_options, source_line_count: PutsDebuggerer.source_line_count, run_number: run_number, pd_inspect: pd_inspect, logger_formatter_decorated: logger_formatter_decorated, logging_layouts_decorated: logging_layouts_decorated)
        stdout = $stdout
        $stdout = sio = StringIO.new
        PutsDebuggerer.formatter.call(formatter_pd_data)
        $stdout = stdout
        string = sio.string
        if PutsDebuggerer.printer.is_a?(Proc)
          PutsDebuggerer.printer.call(string)
        elsif PutsDebuggerer.printer.is_a?(Logger)
          logger_formatter = PutsDebuggerer.printer.formatter
          begin
            PutsDebuggerer.printer.formatter = PutsDebuggerer.logger_original_formatter
            PutsDebuggerer.printer.debug(string)
          ensure
            PutsDebuggerer.printer.formatter = logger_formatter
          end
        elsif PutsDebuggerer.printer.is_a?(Logging::Logger)
          logging_layouts = PutsDebuggerer.printer.appenders.reduce({}) do |hash, appender|
            hash.merge(appender => appender.layout)
          end
          begin
            PutsDebuggerer.logging_original_layouts.each do |appender, original_layout|
              appender.layout = original_layout
            end
            PutsDebuggerer.printer.debug(string)
          ensure
            PutsDebuggerer.logging_original_layouts.each do |appender, original_layout|
              appender.layout = logging_layouts[appender]
            end
          end        
        elsif PutsDebuggerer.printer != false
          send(PutsDebuggerer.send(:printer), string)
        end
      end
    end
  
    printer ? object : string
  end

  # Implement caller backtrace method in Opal since it returns an empty array in Opal v1
  if RUBY_PLATFORM == 'opal'
    def caller
      begin
        raise 'error'
      rescue => e
        e.backtrace[3..-1]
      end
    end
  end
  
  def pd_inspect
    pd self, printer: false, pd_inspect: true
  end
  alias pdi pd_inspect
  
  # Provides caller line number starting 1 level above caller of
  # this method.
  #
  # Example:
  #
  #   # lib/example.rb                        # line 1
  #   puts "Print out __caller_line_number__" # line 2
  #   puts __caller_line_number__             # line 3
  #
  # prints out `3`
  def __caller_line_number__(caller_depth=0)
    return if RUBY_PLATFORM == 'opal'
    caller[caller_depth] && caller[caller_depth][PutsDebuggerer::STACK_TRACE_CALL_LINE_NUMBER_REGEX, 1].to_i
  end
  
  # Provides caller file starting 1 level above caller of
  # this method.
  #
  # Example:
  #
  #   # File Name: lib/example.rb
  #   puts __caller_file__
  #
  # prints out `lib/example.rb`
  def __caller_file__(caller_depth=0)
    regex = RUBY_PLATFORM == 'opal' ? PutsDebuggerer::STACK_TRACE_CALL_SOURCE_FILE_REGEX_OPAL : PutsDebuggerer::STACK_TRACE_CALL_SOURCE_FILE_REGEX
    caller[caller_depth] && caller[caller_depth][regex, 1]  
  end
  
  
  # Provides caller source line starting 1 level above caller of
  # this method.
  #
  # Example:
  #
  #   puts __caller_source_line__
  #
  # prints out `puts __caller_source_line__`
  def __caller_source_line__(caller_depth=0, source_line_count=nil, source_file=nil, source_line_number=nil)
    source_line_number ||= __caller_line_number__(caller_depth+1)
    source_file ||= __caller_file__(caller_depth+1)
    source_line = ''
    if source_file == '(irb)'
      source_line = conf.io.line(source_line_number) # TODO handle multi-lines in source_line_count
    else
      source_line = PutsDebuggerer::SourceFile.new(source_file).source(source_line_count, source_line_number)
    end
    source_line
  end
  
  private
  
  def __with_pd_options__(options=nil)
    options ||= {}
    permanent_options = PutsDebuggerer.options
    PutsDebuggerer.options = options.select {|option, _| PutsDebuggerer.options.keys.include?(option)}
    print_engine_options = options.delete_if {|option, _| PutsDebuggerer.options.keys.include?(option)}
    yield print_engine_options
    PutsDebuggerer.options = permanent_options
  end
  
  def __build_pd_data__(object, print_engine_options:nil, source_line_count:nil, run_number:nil, pd_inspect:false, logger_formatter_decorated:false, logging_layouts_decorated:false)
    depth = RUBY_PLATFORM == 'opal' ? PutsDebuggerer::CALLER_DEPTH_ZERO_OPAL : PutsDebuggerer::CALLER_DEPTH_ZERO
    if pd_inspect
      depth += 1
      depth += 4 if logger_formatter_decorated
      depth += 8 if logging_layouts_decorated
    end
  
    pd_data = {
      announcer: PutsDebuggerer.announcer,
      file: __caller_file__(depth)&.sub(PutsDebuggerer.app_path.to_s, ''),
      line_number: __caller_line_number__(depth),
      pd_expression: __caller_pd_expression__(depth, source_line_count),
      run_number: run_number,
      object: object,
      object_printer: PutsDebuggerer::OBJECT_PRINTER_DEFAULT.call(object, print_engine_options, source_line_count, run_number)
    }
    pd_data[:caller] = __caller_caller__(depth)
    ['header', 'wrapper', 'footer'].each do |boundary_option| 
      pd_data[boundary_option.to_sym] = PutsDebuggerer.send(boundary_option) if PutsDebuggerer.send("#{boundary_option}?")
    end
    pd_data
  end
  
  # Returns the caller stack trace of the caller of pd
  def __caller_caller__(depth)
    return unless PutsDebuggerer.caller?
    start_depth = depth.to_i + 1
    caller_depth = PutsDebuggerer.caller == -1 ? -1 : (start_depth + PutsDebuggerer.caller)
    caller[start_depth..caller_depth].to_a
  end
  
  def __format_pd_expression__(expression, object)
    "\n   > #{expression}\n  =>"
  end
  
  def __caller_pd_expression__(depth=0, source_line_count=nil)
    # Caller Source Line Depth 2 = 1 to pd method + 1 to caller
    source_line = __caller_source_line__(depth+1, source_line_count)
    source_line = __extract_pd_expression__(source_line)
    source_line = source_line.gsub(/(^'|'$)/, '"') if source_line.start_with?("'") && source_line.end_with?("'")
    source_line = source_line.gsub(/(^\(|\)$)/, '') if source_line.start_with?("(") && source_line.end_with?(")")
    source_line
  end
  
  # Extracts pd source line expression.
  #
  # Example:
  #
  # __extract_pd_expression__("pd (x=1)")
  #
  # outputs `(x=1)`
  def __extract_pd_expression__(source_line)
    source_line.to_s.strip
  end  
end
