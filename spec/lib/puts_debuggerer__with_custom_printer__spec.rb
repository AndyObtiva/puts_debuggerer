require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  before do
    load "awesome_print/core_ext/kernel.rb"
    @awesome_print_defaults = AwesomePrint.defaults
    AwesomePrint.defaults = {
      plain: true
    }
    $stdout = StringIO.new
    PutsDebuggerer.print_engine = :ap
    PutsDebuggerer.formatter = nil
    PutsDebuggerer.header = nil
    PutsDebuggerer.footer = nil
    PutsDebuggerer.caller = nil
  end

  context 'with custom printer engine' do
    let(:expected_object_printout) {
      "[\n    [0] 1,\n    [1] [\n        [0] 2,\n        [1] 3\n    ]\n]"
    }
    let(:expected_object_printout_awesome_print) {
      "[\\n    [0] 1,\\n    [1] [\\n        [0] 2,\\n        [1] 3\\n    ]\\n]"
    }
    before do
      PutsDebuggerer.printer = nil
    end
    after do
      PutsDebuggerer.printer = nil
      Object.send(:remove_const, :Rails) rescue nil
    end
    it 'prints using passed in custom lambda print engine' do
      PutsDebuggerer.printer = lambda {|text| puts "\n#{text}\n"} #intentionally set as :p
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n\n")
    end
    xit 'prints using Rails lambda print engine' do
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
        end
      end
      PutsDebuggerer.printer = nil #defaults to Rails logger debug printing
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("Rails.logger.debug: [PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object with default :puts printer' do
      expect(PutsDebuggerer.printer).to eq(:puts)
      PutsDebuggererInvoker.static_nested_array
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:22\n   > pd [1, [2, 3]]\n  => #{expected_object_printout}\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object with specified :print printer' do
      PutsDebuggerer.printer = :ap
      expect(PutsDebuggerer.printer).to eq(:ap)
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("\"[PD] #{puts_debuggerer_invoker_file}:26\\n   > pd array, options\\n  => #{expected_object_printout_awesome_print}\\n\"\n")
    end
    it 'raises informative error if print_engine was invalid' do
      expect {PutsDebuggerer.printer = :invalid}.to raise_error('printer must be a valid global method symbol (e.g. :puts) or lambda/proc receiving a text arg')
    end
  end

end
