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
  context 'with footer support enabled' do
    context 'as default footer' do
      before do
        PutsDebuggerer.footer = true
      end
      after do
        PutsDebuggerer.footer = nil
      end
      it 'prints asterisk footer 80 times by default before dynamic PD print out' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      end
      it 'disables footer with nil footer' do
        PutsDebuggerer.footer = nil
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
      it 'disables footer with false footer' do
        PutsDebuggerer.footer = false
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
      it 'disables footer with empty string footer' do
        PutsDebuggerer.footer = ''
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
    end
    context 'as custom footer' do
      let(:custom_footer) {'>>>PRINT OUT<<<'}
      before do
        PutsDebuggerer.footer = custom_footer
      end
      after do
        PutsDebuggerer.footer = nil
      end
      it 'prints asterisk footer 80 times by default before dynamic PD print out' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n#{custom_footer}\n")
      end
    end
  end
end
