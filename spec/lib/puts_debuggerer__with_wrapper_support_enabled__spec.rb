require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  context 'with wrapper support enabled' do
    context 'as default wrapper' do
      before do
        PutsDebuggerer.wrapper = true
      end
      it 'prints asterisk wrapper 80 times by default before dynamic PD print out' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("#{PutsDebuggerer::WRAPPER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n#{PutsDebuggerer::WRAPPER_DEFAULT}\n")
      end
      it 'disables wrapper with nil wrapper' do
        PutsDebuggerer.wrapper = nil
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
      it 'disables wrapper with false wrapper' do
        PutsDebuggerer.wrapper = false
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
      it 'disables wrapper with empty string wrapper' do
        PutsDebuggerer.wrapper = ''
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
    end
    context 'as custom wrapper' do
      let(:custom_wrapper) {'>>>PRINT OUT<<<'}
      before do
        PutsDebuggerer.wrapper = custom_wrapper
      end
      after do
        PutsDebuggerer.wrapper = nil
      end
      it 'prints asterisk wrapper 80 times by default before dynamic PD print out' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("#{custom_wrapper}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n#{custom_wrapper}\n")
      end
    end
  end
end
