if RUBY_VERSION >= '2.3' && !defined?(Rubinius)
  begin
    require 'coveralls'
    Coveralls.wear!
  rescue LoadError, StandardError => e
    #no op to support Rubies that do not support Coveralls
    puts 'Error loading Coveralls'
    puts e.message
    puts e.backtrace.join("\n")
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'puts_debuggerer'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

end
