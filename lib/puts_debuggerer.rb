module PutsDebuggerer
  HEADER_DEFAULT = '*'*80
  FOOTER_DEFAULT = '*'*80
  PRINT_ENGINE_DEFAULT = :p
  PRINT_ENGINE_MESSAGE_INVALID = 'print_engine must be a valid global method symbol (e.g. :p or :puts)'
  ANNOUNCER_DEFAULT = '[PD]'
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
    #      > (x=1).inspect
    #     => "1"
    def app_path
      (@app_path || Rails.root.to_s) rescue nil
    end

    attr_writer :app_path

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
    #      > (x=1).inspect
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
    # Prints out
    #
    #   [PD] /Users/User/example.rb:2
    #      > (x=1).inspect
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
    #
    # Example:
    #
    #   # File Name: /Users/User/example.rb
    #   require 'awesome_print'
    #   PutsDebuggerer.print_engine = :ap
    #   array = [1, [2, 3]]
    #   pd array
    #
    # Prints out
    #
    #   [PD] /Users/User/example.rb:5
    #      > (array).inspect
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
        @print_engine = PRINT_ENGINE_DEFAULT
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
    # Prints out
    #
    #   *** PD ***
    #      /Users/User/example.rb:2
    #      > (x=1).inspect
    #     => "1"
    attr_reader :announcer

    def announcer=(text)
      @announcer = text.nil? ? ANNOUNCER_DEFAULT : text
    end
  end
end

PutsDebuggerer.print_engine = PutsDebuggerer::PRINT_ENGINE_DEFAULT
PutsDebuggerer.announcer = PutsDebuggerer::ANNOUNCER_DEFAULT

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
#      > ("Show me the source of the bug: #{bug}").inspect
#     => "Show me the source of the bug: beattle"
#   [PD] /Users/User/finance_calculator_app/pd_test.rb:4 "What line number am I?"
def pd(object, options=nil)
  header = PutsDebuggerer.header? ? "#{PutsDebuggerer.header}\n" : ''
  announcer = PutsDebuggerer.announcer
  file = __caller_file__(1).sub(PutsDebuggerer.app_path.to_s, '')
  line_number = __caller_line_number__(1)
  pd_expression = __caller_pd_expression__(object)
  print "#{header}#{announcer} #{file}:#{line_number}#{pd_expression} "
  if options.nil? || options == {}
    send(PutsDebuggerer.print_engine, object)
  else
    send(PutsDebuggerer.print_engine, object, options) rescue send(PutsDebuggerer.print_engine, object)
  end
  puts PutsDebuggerer.footer if PutsDebuggerer.footer?
end


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
def __caller_source_line__(caller_depth=0)
  source_line_number = __caller_line_number__(caller_depth+1)
  source_file = __caller_file__(caller_depth+1)
  source_line = nil
  if source_file == '(irb)'
    source_line = conf.io.line(source_line_number)
  else
    File.open(source_file, 'r') do |f|
      lines = f.readlines
      source_line = lines[source_line_number-1]
    end
  end
  source_line
end

private

def __caller_pd_expression__(object)
  # Caller Source Line Depth 2 = 1 to pd method + 1 to caller
  source_line = __caller_source_line__(2)
  source_line = __extract_pd_expression__(source_line)
  source_line = source_line.gsub(/(^'|'$)/, '"') if source_line.start_with?("'") && source_line.end_with?("'")
  source_line = source_line.gsub(/(^\(|\)$)/, '') if source_line.start_with?("(") && source_line.end_with?(")")
  if source_line == object.inspect.sub("\n$", '')
    ""
  else
    "\n   > (#{source_line}).inspect\n  =>"
  end
end

# Extracts pd source line expression.
#
# Example:
#
# __extract_pd_expression__("pd (x=1)")
#
# outputs `(x=1)`
def __extract_pd_expression__(source_line)
  source_line.strip.sub(/^[ ]*pd[ ]+/, '').strip
end
