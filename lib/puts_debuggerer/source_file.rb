module PutsDebuggerer
  class SourceFile  
    def initialize(path)
      @path = path
    end
    
    def source(source_line_count, source_line_number)
      @source = ''
      f = File.new(@path)
      if f.respond_to?(:readline) # Opal Ruby Compatibility
        source_lines = []
        begin
          while f.lineno < source_line_number + source_line_count
            file_line_number = f.lineno + 1
            file_line = f.readline
            if file_line_number >= source_line_number && file_line_number < source_line_number + source_line_count
              source_lines << file_line
            end
          end
        rescue EOFError
          # Done
        end
        @source = source_lines.join(' '*5)
      end
      @source    
    end
  end
end
