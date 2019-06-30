require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  before do
    $stdout = StringIO.new
    PutsDebuggerer.printer = :puts
    PutsDebuggerer.print_engine = :p
    PutsDebuggerer.formatter = nil
    PutsDebuggerer.header = nil
    PutsDebuggerer.footer = nil
    PutsDebuggerer.caller = nil
    PutsDebuggerer.app_path = nil
  end
  context 'with app path provided' do
    before do
      PutsDebuggerer.app_path = File.expand_path(File.join(__FILE__, '..', '..', '..'))
    end
    after do
      PutsDebuggerer.app_path = nil
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] /spec/support/puts_debuggerer_invoker.rb:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
    end
  end
end
