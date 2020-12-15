require File.expand_path(File.dirname(__FILE__) + '../../../lib/puts_debuggerer')

# DO NOT MOVE METHODS (LINE NUMBERS ARE BEING TESTED) ADD METHODS AT THE END ONLY
module PutsDebuggererInvoker
  # intentional empty line
  # intentional empty line
  # intentional empty line
  # intentional empty line
  def self.dynamic_greeting(name)
    pd "Hello #{name}"
  end
  # intentional empty line
  def self.parentheses_dynamic_greeting(name)
    pd ("Hello #{name}")
  end
  # intentional empty line
  def self.numeric_squaring(n)
    pd n*n
  end
  # intentional empty line
  def self.static_nested_array
    pd [1, [2, 3]]
  end
  # intentional empty line
  def self.dynamic_nested_array(*array_including_options)
    pd *array_including_options
  end
  # intentional empty line
  def self.multi_line_dynamic_greeting(name)
    pd "Hello " +
      name.to_s
  end
  # intentional empty line
  def self.inside_dynamic_greeting(name)
    greeting = "Hello #{pd(name)}"
  end
  # intentional empty line
  def self.dynamic_greeting_run_at(name, run_at=nil)
    pd "Hello #{name}", run_at: run_at
  end
  # intentional empty line
  def self.multi_line_dynamic_greeting_source_line_count(name)
    pd "Hello " +
      name.to_s, source_line_count: 2
  end
  # intentional empty line
  def self.exception_stack_trace(error)
    pd error
  end
  # intentional empty line
  def self.vararg_array
    pd 'hello', 3, true
  end
  # intentional empty line
  def self.vararg_array_with_options(options)
    pd 'hello', 3, true, options
  end
  # intentional empty line
  def self.call_pd(*args)
    pd *args
  end
  # intentional empty line
  def self.logger_log(logger, severity, *args)
    logger.send(severity, *args)
  end
  # intentional empty line
  def self.call_pd_inspect(object)
    object.pd_inspect
  end
end
