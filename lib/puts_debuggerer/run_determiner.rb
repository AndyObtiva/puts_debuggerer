module PutsDebuggerer
  module RunDeterminer
    OBJECT_RUN_AT = {}

    class << self
      attr_reader :run_at_global_number
  
      def run_at_global_number=(value)
        @run_at_global_number = value
      end
  
      def init_run_at_global_number
        @run_at_global_number = 1
      end
  
      def increment_run_at_global_number
        @run_at_global_number += 1
      end
  
      def reset_run_at_global_number
        @run_at_global_number = nil
      end
  
      def run_at_number(object, run_at)
        OBJECT_RUN_AT[[object,run_at]]
      end
  
      def init_run_at_number(object, run_at)
        OBJECT_RUN_AT[[object,run_at]] = 1
      end
  
      def increment_run_at_number(object, run_at)
        OBJECT_RUN_AT[[object,run_at]] += 1
      end
  
      def reset_run_at_number(object, run_at)
        OBJECT_RUN_AT.delete([object, run_at])
      end
  
      def reset_run_at_numbers
        OBJECT_RUN_AT.clear
      end    
    end
  end
end
