require 'awesome_print' unless RUBY_PLATFORM == 'opal'
require 'stringio'

require 'puts_debuggerer/run_determiner'
require 'puts_debuggerer/source_file'

module PutsDebuggerer
  SOURCE_LINE_COUNT_DEFAULT = 1
  HEADER_DEFAULT = '*'*80
  WRAPPER_DEFAULT = '*'*80
  FOOTER_DEFAULT = '*'*80
  RETURN_DEFAULT = true
  OBJECT_PRINTER_DEFAULT = lambda do |object, print_engine_options=nil, source_line_count=nil, run_number=nil|
    lambda do
      if object.is_a?(Exception) && object.respond_to?(:full_message)
        puts object.full_message
      elsif PutsDebuggerer.print_engine.is_a?(Proc)
        PutsDebuggerer.print_engine.call(object)
      else
        send(PutsDebuggerer.print_engine, object)
      end
    end
  end
  PRINTER_DEFAULT = :puts
  PRINTER_RAILS = lambda do |output|
    puts output if Rails.env.test?
    Rails.logger.debug(output)
  end
  PRINT_ENGINE_DEFAULT = :ap
  PRINTER_MESSAGE_INVALID = 'printer must be a valid global method symbol (e.g. :puts), a logger, or a lambda/proc receiving a text arg'
  PRINT_ENGINE_MESSAGE_INVALID = 'print_engine must be a valid global method symbol (e.g. :p, :ap or :pp) or lambda/proc receiving an object arg'
  ANNOUNCER_DEFAULT = '[PD]'
  FORMATTER_DEFAULT = -> (data) {
      puts data[:wrapper] if data[:wrapper]
      puts data[:header] if data[:header]
      print "#{data[:announcer]} #{data[:file]}:#{data[:line_number]}#{" (run:#{data[:run_number]})" if data[:run_number]}#{__format_pd_expression__(data[:pd_expression], data[:object])} "
      data[:object_printer].call
      puts data[:caller].map {|l| '     ' + l} unless data[:caller].to_a.empty?
      puts data[:footer] if data[:footer]
      puts data[:wrapper] if data[:wrapper]
    }
  CALLER_DEPTH_ZERO = 4 #depth includes pd + with_options method + nested block + build_pd_data method
  STACK_TRACE_CALL_LINE_NUMBER_REGEX = /\:(\d+)\:in /
  STACK_TRACE_CALL_SOURCE_FILE_REGEX = /[ ]*([^:]+)\:\d+\:in /

  class << self
    # Application root path to exclude when printing out file path
    #
    # Example:
    #
    #   # File Name: /Users/User/sample_app/lib/sample.rb
    #   PutsDebuggerer.app_path = '/Users/User/sample_app'
    #   pd (x=1)
    #
    # Prints out:
    #
    #   [PD] lib/sample.rb:3
    #      > pd x=1
    #     => "1"
    attr_reader :app_path

    def app_path=(path)
      @app_path = (path || Rails.root.to_s) rescue nil
    end

    # Source Line Count.
    # * Default value is `1`
    #
    # Example:
    #
    #   PutsDebuggerer.source_line_count = 2
    #   pd (true ||
    #     false), source_line_count: 2
    #
    # Prints out:
    #
    #   ********************************************************************************
    #   [PD] /Users/User/example.rb:2
    #      > pd (true ||
    #          false), source_line_count: 2
    #     => "true"
    attr_reader :source_line_count

    def source_line_count=(value)
      @source_line_count = value || SOURCE_LINE_COUNT_DEFAULT
    end

    # Header to include at the top of every print out.
    # * Default value is `nil`
    # * Value `true` enables header as `'*'*80`
    # * Value `false`, `nil`, or empty string disables header
    # * Any other string value gets set as a custom header
    #
    # Example:
    #
    #   PutsDebuggerer.header = true
    #   pd (x=1)
    #
    # Prints out:
    #
    #   ********************************************************************************
    #   [PD] /Users/User/example.rb:2
    #      > pd x=1
    #     => "1"
    attr_reader :header

    # Wrapper to include at the top and bottom of every print out (both header and footer).
    # * Default value is `nil`
    # * Value `true` enables wrapper as `'*'*80`
    # * Value `false`, `nil`, or empty string disables wrapper
    # * Any other string value gets set as a custom wrapper
    #
    # Example:
    #
    #   PutsDebuggerer.wrapper = true
    #   pd (x=1)
    #
    # Prints out:
    #
    #   [PD] /Users/User/example.rb:2
    #      > pd x=1
    #     => "1"
    #   ********************************************************************************
    attr_reader :wrapper

    # Footer to include at the bottom of every print out.
    # * Default value is `nil`
    # * Value `true` enables footer as `'*'*80`
    # * Value `false`, `nil`, or empty string disables footer
    # * Any other string value gets set as a custom footer
    #
    # Example:
    #
    #   PutsDebuggerer.footer = true
    #   pd (x=1)
    #
    # Prints out:
    #
    #   [PD] /Users/User/example.rb:2
    #      > pd x=1
    #     => "1"
    #   ********************************************************************************
    attr_reader :footer
    
    ['header', 'footer', 'wrapper'].each do |boundary_option|
      define_method("#{boundary_option}=") do |value|
        if value.equal?(true)
          instance_variable_set(:"@#{boundary_option}", const_get(:"#{boundary_option.upcase}_DEFAULT"))
        elsif value == ''
          instance_variable_set(:"@#{boundary_option}", nil)
        else
          instance_variable_set(:"@#{boundary_option}", value)
        end      
      end
      
      define_method("#{boundary_option}?") do
        !!instance_variable_get(:"@#{boundary_option}")
      end
    end

    # Printer is a global method symbol or lambda expression to use in printing to the user.
    # Examples of global methods are `:puts` and `:print`.
    # An example of a lambda expression is `lambda {|output| Rails.logger.ap(output)}`
    #
    # Defaults to `:puts`
    # In Rails, it defaults to: `lambda {|output| Rails.logger.ap(output)}`
    #
    # Example:
    #
    # # File Name: /Users/User/example.rb
    # PutsDebuggerer.printer = lambda {|output| Rails.logger.error(output)}
    # str = "Hello"
    # pd str
    #
    # Prints out in the Rails app log as error lines:
    #
    # [PD] /Users/User/example.rb:5
    #    > pd str
    #   => Hello
    attr_reader :printer

    def printer=(printer)
      if printer.nil?
        @printer = printer_default
      elsif printer == false || printer.is_a?(Proc) || printer.respond_to?(:debug) # a logger
        @printer = printer      
      else
        @printer = method(printer).name rescue raise(PRINTER_MESSAGE_INVALID)
      end
    end
    
    def printer_default
      Object.const_defined?(:Rails) ? PRINTER_RAILS : PRINTER_DEFAULT    
    end

    # Print engine is similar to `printer`, except it is focused on the scope of formatting
    # the data object being printed (excluding metadata such as file name, line number,
    # and expression, which are handled by the `printer`).
    # As such, it is also a global method symbol or lambda expression.
    # Examples of global methods are `:p`, `:ap`, and `:pp`.
    # An example of a lambda expression is `lambda {|object| puts object.to_a.join(" | ")}`
    #
    # Defaults to [awesome_print](https://github.com/awesome-print/awesome_print).
    #
    # Example:
    #
    #   # File Name: /Users/User/example.rb
    #   require 'awesome_print'
    #   PutsDebuggerer.print_engine = :p
    #   array = [1, [2, 3]]
    #   pd array
    #
    # Prints out:
    #
    #   [PD] /Users/User/example.rb:5
    #      > pd array
    #     => [1, [2, 3]]
    #   ]
    attr_reader :print_engine

    def print_engine=(engine)
      if engine.nil?
        @print_engine = print_engine_default
      elsif engine.is_a?(Proc)
        @print_engine = engine
      else
        @print_engine = method(engine).name rescue raise(PRINT_ENGINE_MESSAGE_INVALID)
      end
    end
    
    def print_engine_default
      Object.const_defined?(:AwesomePrint) ? PRINT_ENGINE_DEFAULT : :p    
    end

    # The `return` option specifies whether to return the object being printed (default) or not (i.e. return
    # the string being printed instead.)
    # The purpose of returning object by default is to enable chaining pd statements safely (e.g. `pd x = ([pd(value1), value2])`)
    # and avoid pd from interrupting the flow of execution or affecting the logic in any way.
    # Values may be true (return object) or false (do not return object, returning printed string instead)
    #
    # Defaults to `true`
    #
    # Example:
    #
    #   # File Name: /Users/User/example.rb
    #   array = [1, [2, 3]]
    #   pd array, return: false
    #
    # Prints out:
    #
    #   [PD] /Users/User/example.rb:3
    #      > pd array, return: false
    #     => [1, [2, 3]]
    #   ]
    #
    # Returns:
    #
    # "[1, [2, 3]]"
    attr_reader :return

    def return=(return_object)
      @return = return_object.nil? ? RETURN_DEFAULT : return_object
    end
    
    # Announcer (e.g. [PD]) to announce every print out with (default: "[PD]")
    #
    # Example:
    #
    #   PutsDebuggerer.announcer = "*** PD ***\n  "
    #   pd (x=1)
    #
    # Prints out:
    #
    #   *** PD ***
    #      /Users/User/example.rb:2
    #      > pd x=1
    #     => 1
    attr_reader :announcer

    def announcer=(text)
      @announcer = text.nil? ? ANNOUNCER_DEFAULT : text
    end

    # Formatter used in every print out
    # Passed a data argument with the following keys:
    # * :announcer (string)
    # * :caller (array)
    # * :file (string)
    # * :wrapper (string)
    # * :footer (string)
    # * :header (string)
    # * :line_number (string)
    # * :pd_expression (string)
    # * :object (object)
    # * :object_printer (proc)
    # * :source_line_count (integer)
    #
    # NOTE: data for :object_printer is not a string, yet a proc that must
    # be called to output value. It is a proc as it automatically handles usage
    # of print_engine and encapsulates its details. In any case, data for :object
    # is available should one want to avoid altogether.
    #
    # Example:
    #
    #   PutsDebuggerer.formatter = -> (data) {
    #     puts "-<#{data[:announcer]}>-"
    #     puts "HEADER: #{data[:header]}"
    #     puts "FILE: #{data[:file]}"
    #     puts "LINE: #{data[:line_number]}"
    #     puts "EXPRESSION: #{data[:pd_expression]}"
    #     print "PRINT OUT: "
    #     data[:object_printer].call
    #     puts "CALLER: #{data[:caller].to_a.first}"
    #     puts "FOOTER: #{data[:footer]}"
    #   }
    #   pd (x=1)
    #
    # Prints out:
    #
    #   -<[PD]>-
    #   FILE: /Users/User/example.rb
    #   HEADER: ********************************************************************************
    #   LINE: 9
    #   EXPRESSION: x=1
    #   PRINT OUT: 1
    #   CALLER: #/Users/User/master_examples.rb:83:in `block (3 levels) in <top (required)>'
    #   FOOTER: ********************************************************************************
    attr_reader :formatter

    def formatter=(formatter_proc)
      @formatter = formatter_proc.nil? ? FORMATTER_DEFAULT : formatter_proc
    end

    # Caller backtrace included at the end of every print out
    # Passed an argument of true/false, nil, or depth as an integer.
    # * true and -1 means include full caller backtrace
    # * false and nil means do not include caller backtrace
    # * depth (0-based) means include limited caller backtrace depth
    #
    # Example:
    #
    #   # File Name: /Users/User/sample_app/lib/sample.rb
    #   PutsDebuggerer.caller = 3
    #   pd (x=1)
    #
    # Prints out:
    #
    #   [PD] /Users/User/sample_app/lib/sample.rb:3
    #      > pd x=1
    #     => "1"
    #        /Users/User/sample_app/lib/master_samples.rb:368:in `block (3 levels) in <top (required)>'
    #        /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/workspace.rb:87:in `eval'
    #        /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/workspace.rb:87:in `evaluate'
    #        /Users/User/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/irb/context.rb:381:in `evaluate'
    attr_reader :caller

    def caller=(value)
      if value.equal?(true)
        @caller = -1 #needed for upper bound in pd method
      else
        @caller = value
      end
    end

    def caller?
      !!caller
    end


    # Options as a hash. Useful for reading and backing up options
    def options
      {
        header: header,
        wrapper: wrapper,
        footer: footer,
        printer: printer,
        print_engine: print_engine,
        source_line_count: source_line_count,
        app_path: app_path,
        announcer: announcer,
        formatter: formatter,
        caller: caller,
        run_at: run_at
      }
    end

    # Sets options included in hash
    def options=(hash)
      hash.each do |option, value|
        send("#{option}=", value)
      end
    end

    # When to run as specified by an index, array, or range.
    # * Default value is `nil` meaning always
    # * Value as an Integer index (1-based) specifies at which run to print once
    # * Value as an Array of indices specifies at which runs to print multiple times
    # * Value as a range specifies at which runs to print multiple times,
    #   indefinitely if it ends with ..-1
    #
    # Example:
    #
    #   PutsDebuggerer.run_at = 1
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.run_at = 2
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #
    #   PutsDebuggerer.run_at = [1, 3]
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.run_at = 3..5
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.run_at = 3...6
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.run_at = 3..-1
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) ... continue printing indefinitely on all subsequent runs
    #
    #   PutsDebuggerer.run_at = 3...-1
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) ... continue printing indefinitely on all subsequent runs
    attr_reader :run_at

    def run_at=(value)
      @run_at = value
    end

    def run_at?
      !!@run_at
    end

    def determine_options(objects)    
      objects.delete_at(-1) if objects.size > 1 && objects.last.is_a?(Hash)
    end

    def determine_object(objects)
      objects.compact.size > 1 ? objects : objects.first
    end

    def determine_run_at(options)
      ((options && options[:run_at]) || PutsDebuggerer.run_at)
    end

    def determine_printer(options)
      if options && options.has_key?(:printer)
        options[:printer]
      else
        PutsDebuggerer.printer
      end
    end
  end
end

# setting values to nil defaults them properly
PutsDebuggerer.printer = nil
PutsDebuggerer.print_engine = nil
PutsDebuggerer.announcer = nil
PutsDebuggerer.formatter = nil
PutsDebuggerer.app_path = nil
PutsDebuggerer.caller = nil
PutsDebuggerer.return = nil
PutsDebuggerer.run_at = nil
PutsDebuggerer.source_line_count = nil

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
  options = PutsDebuggerer.determine_options(objects)
  object = PutsDebuggerer.determine_object(objects)
  run_at = PutsDebuggerer.determine_run_at(options)
  printer = PutsDebuggerer.determine_printer(options)

  string = nil
  if PutsDebuggerer::RunDeterminer.run_pd?(object, run_at)
    __with_pd_options__(options) do |print_engine_options|
      run_number = PutsDebuggerer::RunDeterminer.run_number(object, run_at)
      formatter_pd_data = __build_pd_data__(object, print_engine_options, PutsDebuggerer.source_line_count, run_number) #depth adds build method
      stdout = $stdout
      $stdout = sio = StringIO.new
      PutsDebuggerer.formatter.call(formatter_pd_data)
      $stdout = stdout
      string = sio.string
      if PutsDebuggerer.printer.is_a?(Proc)
        PutsDebuggerer.printer.call(string)
      elsif PutsDebuggerer.printer.respond_to?(:debug)
        PutsDebuggerer.printer.debug(string)
      elsif PutsDebuggerer.printer != false
        send(PutsDebuggerer.send(:printer), string)
      end
    end
  end

  printer ? object : string
end

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
  caller[caller_depth] && caller[caller_depth][PutsDebuggerer::STACK_TRACE_CALL_SOURCE_FILE_REGEX, 1]
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

def __build_pd_data__(object, print_engine_options=nil, source_line_count=nil, run_number=nil)
  depth = PutsDebuggerer::CALLER_DEPTH_ZERO
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
