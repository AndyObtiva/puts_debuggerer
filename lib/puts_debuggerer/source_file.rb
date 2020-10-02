module PutsDebuggerer
  class SourceFile  
    def initialize(file_path)
      @file = File.new(file_path) if file_path
    end
    
    def source(source_line_count, source_line_number)
      @source = ''      
      return @source if RUBY_PLATFORM == 'opal'
      # For Opal Ruby compatibility, skip source lines if file does not respond to readline (as in Opal)
      lines = source_lines(source_line_count, source_line_number)
      @source = lines.join(' '*5) if @file.respond_to?(:readline)
      @source    
    end
    
    def source_lines(source_line_count, source_line_number)
      lines = []
      return lines if RUBY_PLATFORM == 'opal'
      begin
        while @file.lineno < source_line_number + source_line_count
          file_line_number = @file.lineno + 1
          file_line = @file.readline
          if file_line_number >= source_line_number && file_line_number < source_line_number + source_line_count
            lines << file_line
          end
        end
      rescue EOFError
        # Done
      end
      lines
    end
  end
end
