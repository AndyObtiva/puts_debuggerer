require File.expand_path(File.dirname(__FILE__) + '../../../lib/puts_debuggerer')


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
end
