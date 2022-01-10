require 'ostruct'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  
  before do
    now = Time.new(2000, 1, 1, 1, 1, 1, 1)
    Time.stub(:now).and_return(now)
    load "awesome_print/core_ext/kernel.rb"
    @awesome_print_defaults = AwesomePrint.defaults
    AwesomePrint.defaults = {
      plain: true
    }
    PutsDebuggerer.print_engine = :ap
  end
  
  context 'with custom printer' do
    let(:expected_object_printout) {
      "[\n    [0] 1,\n    [1] [\n        [0] 2,\n        [1] 3\n    ]\n]"
    }
    
    let(:expected_object_printout_awesome_print) {
      "[\\n    [0] 1,\\n    [1] [\\n        [0] 2,\\n        [1] 3\\n    ]\\n]"
    }
    
    before do
      Object.send(:remove_const, :Rails) rescue nil
      PutsDebuggerer.app_path = nil
      PutsDebuggerer.printer = nil
    end
    
    after do
      Object.send(:remove_const, :Rails) rescue nil
    end
    
    it 'prints using passed in custom lambda printer' do
      PutsDebuggerer.printer = lambda {|text| puts "\n#{text}\n"} #intentionally set as :p
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n\n")
    end
    
    it 'prints with default :puts printer (file relative to app path, line number, ruby expression, and evaluated string object)' do
      expect(PutsDebuggerer.printer).to eq(:puts)
      PutsDebuggererInvoker.static_nested_array
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:22\n   > pd [1, [2, 3]]\n  => #{expected_object_printout}\n")
    end
    
    it 'prints with specified :print printer (file relative to app path, line number, ruby expression, and evaluated string object)' do
      PutsDebuggerer.printer = :ap
      expect(PutsDebuggerer.printer).to eq(:ap)
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("\"[PD] #{puts_debuggerer_invoker_file}:26\\n   > pd *array_including_options\\n  => #{expected_object_printout_awesome_print}\\n\"\n")
    end
    
    it 'prints with specified logger object (file relative to app path, line number, ruby expression, and evaluated string object)' do
      logger = Logger.new($stdout)
      PutsDebuggerer.printer = logger
      expect(PutsDebuggerer.printer).to eq(logger)
      PutsDebuggererInvoker.static_nested_array
      output = $stdout.string
      expect(output).to eq("D, [2000-01-01T01:01:01.000000 ##{Process.pid}] DEBUG -- : [PD] #{puts_debuggerer_invoker_file}:22\n   > pd [1, [2, 3]]\n  => #{expected_object_printout}\n\n")

      $stdout = StringIO.new
      logger = Logger.new($stdout)
      PutsDebuggerer.printer = logger
      PutsDebuggererInvoker.logger_log logger, 'error', [1, [2, 3]]
      output = $stdout.string
      expect(output).to eq("E, [2000-01-01T01:01:01.000000 ##{Process.pid}] ERROR -- : [PD] #{puts_debuggerer_invoker_file}:64\n   > logger.send(severity, *args)\n  => #{expected_object_printout}\n\n")
    end
    
    it 'prints with specified logging logger object (file relative to app path, line number, ruby expression, and evaluated string object)' do
      logger = Logging.logger['test']
      logger.add_appenders(Logging.appenders.string_io(StringIO.new))
      logger.level = 0
      PutsDebuggerer.printer = logger
      expect(PutsDebuggerer.printer).to eq(logger)
      PutsDebuggererInvoker.static_nested_array
      expected_output1 = "DEBUG  test : [PD] #{puts_debuggerer_invoker_file}:22\n   > pd [1, [2, 3]]\n  => #{expected_object_printout}\n\n"
      
      PutsDebuggererInvoker.logger_log logger, 'error', [1, [2, 3]]
      output = logger.appenders.first.sio.string
      expected_output2 = "ERROR  test : [PD] #{puts_debuggerer_invoker_file}:64\n   > logger.send(severity, *args)\n  => #{expected_object_printout}\n\n"
      expect(output).to eq("#{expected_output1}#{expected_output2}")
    end
    
    it 'does not print with printer globally as false, but returns rendered string instead of object' do
      PutsDebuggerer.printer = false
      expect(PutsDebuggerer.printer).to eq(false)
      return_value = PutsDebuggererInvoker.static_nested_array
      output = $stdout.string
      expect(output).to eq('')
      expect(return_value).to eq("[PD] #{puts_debuggerer_invoker_file}:22\n   > pd [1, [2, 3]]\n  => #{expected_object_printout}\n")
    end
    
    it 'does not print with printer as false, but returns rendered string instead of object' do
      return_value = PutsDebuggererInvoker.call_pd [1, [2, 3]], printer: false
      output = $stdout.string
      expect(output).to eq('')
      expect(return_value).to eq("[PD] #{puts_debuggerer_invoker_file}:60\n   > pd *args\n  => #{expected_object_printout}\n")
    end
    
    it 'raises informative error if print_engine was invalid' do
      expect {PutsDebuggerer.printer = :invalid}.to raise_error('printer must be a valid global method symbol (e.g. :puts), a logger, or a lambda/proc receiving a text arg')
    end
    
    it 'prints using Rails lambda printer' do
      Object.class_eval do
        module Rails
          class Logger
            def debug(object)
              # simulate a Rails logger. Adding extra prefix to ease testing.
              puts "Rails.logger.debug: #{object}"
            end
          end
          def self.root
            File.expand_path(File.join(__FILE__, '..', '..', '..'))
          end
          def self.logger
            @logger ||= Logger.new
          end
          def self.env
            OpenStruct.new(:test? => true)
          end
        end
      end
      PutsDebuggerer.app_path = nil #defaults to Rails logger debug printing
      PutsDebuggerer.printer = nil #defaults to Rails logger debug printing
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq(
        "[PD] /spec/support/puts_debuggerer_invoker.rb:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" +
        "Rails.logger.debug: [PD] /spec/support/puts_debuggerer_invoker.rb:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n"
      )
    end
  end

end
