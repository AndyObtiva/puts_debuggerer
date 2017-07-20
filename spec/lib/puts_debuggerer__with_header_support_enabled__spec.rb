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
  context 'with header support enabled' do
    context 'as default header' do
      before do
        PutsDebuggerer.header = true
      end
      after do
        PutsDebuggerer.header = nil
      end
      it 'prints asterisk header 80 times by default before dynamic PD print out' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
      it 'disables header with nil header' do
        PutsDebuggerer.header = nil
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
      it 'disables header with false header' do
        PutsDebuggerer.header = false
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
      it 'disables header with empty string header' do
        PutsDebuggerer.header = ''
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
    end
    context 'as custom header' do
      let(:custom_header) {'>>>PRINT OUT<<<'}
      before do
        PutsDebuggerer.header = custom_header
      end
      after do
        PutsDebuggerer.header = nil
      end
      it 'prints asterisk header 80 times by default before dynamic PD print out' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("#{custom_header}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
      end
    end
  end
end
