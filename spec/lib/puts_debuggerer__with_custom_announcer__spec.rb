require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}

  context 'with custom announcer' do
    let(:custom_announcer) {'<PD>'}
    before do
      PutsDebuggerer.announcer = custom_announcer
    end
    after do
      PutsDebuggerer.announcer = nil
    end
    it 'changes [PD] to <PD>' do
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("<PD> #{puts_debuggerer_invoker_file}:10 in PutsDebuggererInvoker.dynamic_greeting\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
    end
    it 'resets to default announcer when announcer is set to nil' do
      PutsDebuggerer.announcer = nil
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 in PutsDebuggererInvoker.dynamic_greeting\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
    end
  end
end
