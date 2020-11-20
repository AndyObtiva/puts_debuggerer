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
      
      def run_number(object, run_at)
        run_at_global_number || run_at_number(object, run_at)
      end
            
      def run_pd?(object, run_at)
        run_pd = false
        if run_at.nil?
          run_pd = true
        else
          run_number = determine_run_number(object, run_at)
          run_pd = determine_run_pd(run_at, run_number)
        end
        run_pd
      end
      
      def determine_run_number(object, run_at)
        if PutsDebuggerer.run_at? # check if global option is set
          determine_global_run_number
        else
          determine_local_run_number(object, run_at)
        end
      end
      
      def determine_global_run_number
        if PutsDebuggerer::RunDeterminer.run_at_global_number.nil?
          PutsDebuggerer::RunDeterminer.init_run_at_global_number
        else
          PutsDebuggerer::RunDeterminer.increment_run_at_global_number
        end
        PutsDebuggerer::RunDeterminer.run_at_global_number
      end
      
      def determine_local_run_number(object, run_at)
        if PutsDebuggerer::RunDeterminer.run_at_number(object, run_at).nil?
          PutsDebuggerer::RunDeterminer.init_run_at_number(object, run_at)
        else
          PutsDebuggerer::RunDeterminer.increment_run_at_number(object, run_at)
        end
        PutsDebuggerer::RunDeterminer.run_at_number(object, run_at)
      end
      
      def determine_run_pd(run_at, run_number)
        if run_at.is_a?(Integer)
          determine_run_pd_integer(run_at, run_number)
        elsif run_at.is_a?(Array)
          determine_run_pd_array(run_at, run_number)
        elsif run_at.is_a?(Range)
          determine_run_pd_range(run_at, run_number)
        end
      end
      
      def determine_run_pd_integer(run_at, run_number)
        run_pd = true if run_at == run_number
      end
      
      def determine_run_pd_array(run_at, run_number)
        run_pd = true if run_at.include?(run_number)
      end
      
      def determine_run_pd_range(run_at, run_number)
        run_pd = true if run_at.cover?(run_number) || (run_at.end == -1 && run_number >= run_at.begin)
      end
      
    end
  end
end
