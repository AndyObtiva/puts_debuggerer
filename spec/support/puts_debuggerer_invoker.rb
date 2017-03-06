require File.expand_path(File.dirname(__FILE__) + '../../../lib/puts_debuggerer')

# DO NOT MOVE METHODS (LINE NUMBERS ARE BEING TESTED) ADD METHODS AT THE END ONLY
module PutsDebuggererInvoker
  def self.static_greeting
    pd 'Hello World'
  end

  def self.dynamic_greeting(name)
    pd "Hello #{name}"
  end

  def self.parentheses_dynamic_greeting(name)
    pd ("Hello #{name}")
  end

  def self.numeric_squaring(n)
    pd n*n
  end

  def self.static_nested_array
    pd [1, [2, 3]]
  end

  def self.dynamic_nested_array(array, options = nil)
    pd array, options
  end

  def self.multi_line_dynamic_greeting(name)
    pd "Hello " +
      name.to_s
  end

end
