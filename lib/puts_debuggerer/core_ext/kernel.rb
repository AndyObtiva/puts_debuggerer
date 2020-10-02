module Kernel
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
