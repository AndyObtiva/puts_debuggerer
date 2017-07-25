require 'ripper'

module PutsDebuggerer
  HEADER_DEFAULT = '*'*80
  FOOTER_DEFAULT = '*'*80
  PRINT_ENGINE_DEFAULT = :p
  PRINT_ENGINE_MESSAGE_INVALID = 'print_engine must be a valid global method symbol (e.g. :p or :puts) or lambda/proc'
  ANNOUNCER_DEFAULT = '[PD]'
  FORMATTER_DEFAULT = -> (data) {
      puts data[:header] if data[:header]
      print "#{data[:announcer]} #{data[:file]}:#{data[:line_number]}#{__format_pd_expression__(data[:pd_expression], data[:object])} "
      data[:object_printer].call
      puts data[:caller].map {|l| '     ' + l} unless data[:caller].to_a.empty?
      puts data[:footer] if data[:footer]
    }
  CALLER_DEPTH_ZERO = 4 #depth includes pd + with_options method + nested block + build_pd_data method
  OBJECT_WHEN = {}

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

    def header=(value)
      if value.equal?(true)
        @header = HEADER_DEFAULT
      elsif value == ''
        @header = nil
      else
        @header = value
      end
    end

    def header?
      !!@header
    end

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

    def footer=(value)
      if value.equal?(true)
        @footer = FOOTER_DEFAULT
      elsif value == ''
        @footer = nil
      else
        @footer = value
      end
    end

    def footer?
      !!@footer
    end

    # Print engine to use in object printout (e.g. `p`, `ap`, `pp`).
    # It is represented by the print engine's global method name as a symbol
    # (e.g. `:ap` for awesome_print).
    # Defaults to Ruby's built-in `p` method identified by the symbol `:p`.
    # If it finds awesome_print loaded, it defaults to `ap` as `:ap` instead.
    #
    # Example:
    #
    #   # File Name: /Users/User/example.rb
    #   require 'awesome_print'
    #   PutsDebuggerer.print_engine = :ap
    #   array = [1, [2, 3]]
    #   pd array
    #
    # Prints out:
    #
    #   [PD] /Users/User/example.rb:5
    #      > pd array
    #     => [
    #       [0] 1,
    #       [1] [
    #           [0] 2,
    #           [1] 3
    #       ]
    #   ]
    attr_reader :print_engine

    def print_engine=(engine)
      if engine.nil?
        if Object.const_defined?(:Rails)
          if Object.respond_to?(:ap, 'Hello')
            @print_engine = lambda {|object| Rails.logger.ap(object)}
          else
            @print_engine = lambda {|object| Rails.logger.debug(object)}
          end
        else
          @print_engine = method(:ap).name rescue PRINT_ENGINE_DEFAULT
        end
      elsif engine.is_a?(Proc)
        @print_engine = engine #TODO check that it takes one parameter or else fail fast
      else
        @print_engine = method(engine).name rescue raise(PRINT_ENGINE_MESSAGE_INVALID)
      end
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
    # * :footer (string)
    # * :header (string)
    # * :line_number (string)
    # * :pd_expression (string)
    # * :object (object)
    # * :object_printer (proc)
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
        footer: footer,
        print_engine: print_engine,
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

    # When to print as specified by an index or range.
    # * Default value is `nil` meaning always
    # * Value as an Integer index (0-based) specifies at which run to print once
    # * Value as an Array of indices specifies at which runs to print multiple times
    # * Value as a range specifies at which runs to print multiple times,
    #   indefinitely if it ends with ..-1
    #
    # Example:
    #
    #   PutsDebuggerer.when = 0
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.when = 1
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #
    #   PutsDebuggerer.when = [0, 2]
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.when = 2..5
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.when = 2...5
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) # prints nothing
    #
    #   PutsDebuggerer.when = 2..-1
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints nothing
    #   pd (x=1) # prints standard PD output
    #   pd (x=1) ... continue printing indefinitely on all subsequent runs
    #
    #   PutsDebuggerer.when = 2...-1
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

  end
end

PutsDebuggerer.print_engine = PutsDebuggerer::PRINT_ENGINE_DEFAULT
PutsDebuggerer.announcer = PutsDebuggerer::ANNOUNCER_DEFAULT
PutsDebuggerer.formatter = PutsDebuggerer::FORMATTER_DEFAULT
PutsDebuggerer.app_path = nil #TODO also have it set Rails root on first PD
PutsDebuggerer.caller = nil

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
def pd(object, options=nil)
  run_at = options && options[:run_at]
  execute_pd = false
  if run_at.nil?
    execute_pd = true
  elsif run_at.is_a?(Integer)
    PutsDebuggerer::OBJECT_WHEN[[object,run_at]] = -1 if PutsDebuggerer::OBJECT_WHEN[[object,run_at]].nil?
    PutsDebuggerer::OBJECT_WHEN[[object,run_at]] += 1
    execute_pd = true if run_at == PutsDebuggerer::OBJECT_WHEN[[object,run_at]]
  end

  if execute_pd
    __with_pd_options__(options) do |print_engine_options|
      formatter_pd_data = __build_pd_data__(object, print_engine_options) #depth adds build method
      PutsDebuggerer.formatter.call(formatter_pd_data)
    end
  end

  object
end


# TODO move up and consider placing in module
STACK_TRACE_CALL_LINE_NUMBER_REGEX = /\:(\d+)\:in /
STACK_TRACE_CALL_SOURCE_FILE_REGEX = /[ ]*([^:]+)\:\d+\:in /


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
  caller[caller_depth][STACK_TRACE_CALL_LINE_NUMBER_REGEX, 1].to_i
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
  caller[caller_depth][STACK_TRACE_CALL_SOURCE_FILE_REGEX, 1]
end


# Provides caller source line starting 1 level above caller of
# this method.
#
# Example:
#
#   puts __caller_source_line__
#
# prints out `puts __caller_source_line__`
def __caller_source_line__(caller_depth=0, source_file=nil, source_line_number=nil)
  source_line_number ||= __caller_line_number__(caller_depth+1)
  source_file ||= __caller_file__(caller_depth+1)
  source_line = nil
  if source_file == '(irb)'
    source_line = conf.io.line(source_line_number)
  else
    f = File.new(source_file)
    source_line = ''
    done = false
    f.each_line do |line|
      if !done && f.lineno == source_line_number
        source_line << line
        done = true if Ripper.sexp_raw(source_line) || source_line.include?('%>') #the last condition is for erb support (unofficial)
        source_line_number+=1
      end
    end
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

def __build_pd_data__(object, print_engine_options=nil)
  depth = PutsDebuggerer::CALLER_DEPTH_ZERO
  pd_data = {
    announcer: PutsDebuggerer.announcer,
    file: __caller_file__(depth).sub(PutsDebuggerer.app_path.to_s, ''),
    line_number: __caller_line_number__(depth),
    pd_expression: __caller_pd_expression__(depth),
    object: object,
    object_printer: lambda do
      if PutsDebuggerer.print_engine.is_a?(Proc)
        PutsDebuggerer.print_engine.call(object)
      else
        if print_engine_options.to_h.empty?
          send(PutsDebuggerer.print_engine, object)
        else
          send(PutsDebuggerer.print_engine, object, print_engine_options) rescue send(PutsDebuggerer.print_engine, object)
        end
      end
    end
  }
  if PutsDebuggerer.caller?
    start_depth = depth.to_i
    caller_depth = PutsDebuggerer.caller == -1 ? -1 : (start_depth + PutsDebuggerer.caller)
    pd_data[:caller] = caller[start_depth..caller_depth].to_a
  end
  pd_data[:header] = PutsDebuggerer.header if PutsDebuggerer.header?
  pd_data[:footer] = PutsDebuggerer.footer if PutsDebuggerer.footer?
  pd_data
end

def __format_pd_expression__(expression, object)
  "\n   > #{expression}\n  =>"
end

def __caller_pd_expression__(depth=0)
  # Caller Source Line Depth 2 = 1 to pd method + 1 to caller
  source_line = __caller_source_line__(depth+1)
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
  source_line.strip
end
