def pd(object)
  source_line = __caller_source_line__(1).strip.sub(/^[ ]*pd[ ]+/, '').gsub(/(^'|'$)/, '"')
  if source_line == object.inspect.sub("\n$", '')
    source_line = ''
  else
    source_line += '.inspect => '
  end
  puts "#{__caller_line_number__(1)}: #{source_line}#{object.inspect}"
end

STACK_TRACE_CALL_LINE_NUMBER_REGEX = /\:(\d+)\:in /
STACK_TRACE_CALL_SOURCE_FILE_REGEX = /[ ]*([^:]+)\:\d+\:in /

# Provides caller line number starting 1 level above caller of
# this method.
#
# Example:
# ```ruby
# puts "Print out __caller_line_number__" # line 1
# puts __caller_line_number__             # line 2
# ```
# prints out 2
def __caller_line_number__(caller_depth=0)
  caller[caller_depth][STACK_TRACE_CALL_LINE_NUMBER_REGEX, 1].to_i
end


# Provides caller source line starting 1 level above caller of
# this method.
#
# Example:
# ```ruby
# puts "Print out __caller_line_number__" # line 1
# puts __caller_line_number__             # line 2
# ```
# prints out 2
def __caller_source_line__(caller_depth=0)
  source_line_number = __caller_line_number__(caller_depth+1)
  source_file = caller[caller_depth][STACK_TRACE_CALL_SOURCE_FILE_REGEX, 1]
  source_line = nil
  File.open(source_file, 'r') do |f|
    lines = f.readlines
    source_line = lines[source_line_number-1]
  end
  source_line
end
