require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  before do
    $stdout = StringIO.new
    PutsDebuggerer.print_engine = :p
    PutsDebuggerer.formatter = nil
    PutsDebuggerer.header = nil
    PutsDebuggerer.footer = nil
    PutsDebuggerer.caller = nil
  end
  context 'exception cases' do
    it 'handles multi line ruby expressions correctly' do
      name = 'Robert'
      PutsDebuggererInvoker.multi_line_dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:30\n   > pd \"Hello \" +\n      name.to_s\n  => \"Hello Robert\"\n")
    end
    it 'what if something implements method method?' #e.g. rails request has method implemented to represet http method (bad choice on their part but whatevs)
  end
end
