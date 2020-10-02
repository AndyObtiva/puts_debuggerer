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
        formatter_pd_data = __build_pd_data__(object, print_engine_options, PutsDebuggerer.source_line_count, run_number, pd_inspect, logger_formatter_decorated, logging_layouts_decorated) #depth adds build method
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
end
