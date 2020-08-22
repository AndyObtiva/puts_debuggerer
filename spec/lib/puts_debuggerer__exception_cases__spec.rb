require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  
  before do
    $stdout = StringIO.new
    PutsDebuggerer.print_engine = :p
  end
  
  context 'exception cases' do
    it 'handles multi line ruby expressions correctly' do
      name = 'Robert'
      PutsDebuggererInvoker.multi_line_dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:30\n   > pd \"Hello \" +\n  => \"Hello Robert\"\n")
    end

    it 'handles multi line ruby expressions correctly printing source line count of 2' do
      name = 'Robert'
      PutsDebuggererInvoker.multi_line_dynamic_greeting_source_line_count(name)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:43\n   > pd \"Hello \" +\n           name.to_s, source_line_count: 2\n  => \"Hello Robert\"\n")
    end
  end
end
