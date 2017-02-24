module PutsDebuggerer
  class << self
    attr_writer :app_path

    def app_path
      (@app_path || Rails.root.to_s) rescue nil
    end
  end
end

def pd(object)
  source_line = __caller_source_line__(1).strip.sub(/^[ ]*pd[ ]+/, '').gsub(/(^'|'$)/, '"')
  if source_line == object.inspect.sub("\n$", '')
    source_line = ''
  else
    source_line += '.inspect => '
  end
  line_number = __caller_line_number__(1)
  file = __caller_file__(1).sub(PutsDebuggerer.app_path.to_s, '')
  puts "pd #{file}:#{line_number} #{source_line}#{object.inspect}"
end

STACK_TRACE_CALL_LINE_NUMBER_REGEX = /\:(\d+)\:in /
STACK_TRACE_CALL_SOURCE_FILE_REGEX = /[ ]*([^:]+)\:\d+\:in /

# Provides caller line number starting 1 level above caller of
# this method.
#
# Example:
# ```ruby
# # lib/example.rb                        # line 1
# puts "Print out __caller_line_number__" # line 2
# puts __caller_line_number__             # line 3
# ```
# prints out `3`
def __caller_line_number__(caller_depth=0)
  caller[caller_depth][STACK_TRACE_CALL_LINE_NUMBER_REGEX, 1].to_i
end

# Provides caller file starting 1 level above caller of
# this method.
#
# Example:
# ```ruby
# # lib/example.rb
# puts "Print out __caller_line_number__"
# puts __caller_line_number__
# ```
# prints out `lib/example.rb`
def __caller_file__(caller_depth=0)
  caller[caller_depth][STACK_TRACE_CALL_SOURCE_FILE_REGEX, 1]
end


# Provides caller source line starting 1 level above caller of
# this method.
#
# Example:
# ```ruby
# # lib/example.rb
# puts "Print out __caller_line_number__"
# puts __caller_line_number__
# ```
# prints out `puts __caller_source_line__`
def __caller_source_line__(caller_depth=0)
  source_line_number = __caller_line_number__(caller_depth+1)
  source_file = __caller_file__(caller_depth+1)
  source_line = nil
  File.open(source_file, 'r') do |f|
    lines = f.readlines
    source_line = lines[source_line_number-1]
  end
  source_line
end
