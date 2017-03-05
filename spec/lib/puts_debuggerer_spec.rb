require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  before do
    $stdout = StringIO.new
  end
  it 'prints file, line number, and literal string object' do
    PutsDebuggererInvoker.static_greeting
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated string object' do
    name = 'Muhammad'
    PutsDebuggererInvoker.dynamic_greeting("#{name}")
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated string object without extra parentheses when already surrounded' do
    name = 'Muhammad'
    PutsDebuggererInvoker.parentheses_dynamic_greeting("#{name}")
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:14\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated numeric object without quotes' do
    name = 'Muhammad'
    PutsDebuggererInvoker.numeric_squaring(3)
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:18\n   > (n*n).inspect\n  => 9\n")
  end
  context 'with app path provided' do
    before do
      PutsDebuggerer.app_path = File.expand_path(__FILE__).sub(/spec\/lib\/puts_debuggerer_spec.rb$/, '')
    end
    after do
      PutsDebuggerer.app_path = nil
    end
    it 'prints file relative to app path, line number, and literal string object' do
      PutsDebuggererInvoker.static_greeting
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:6 \"Hello World\"\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting("#{name}")
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
    end
  end
  context 'with rails' do
    before do
      Object.class_eval do
        module Rails
          def self.root
            File.expand_path(__FILE__).sub(/spec\/lib\/puts_debuggerer_spec.rb$/, '')
          end
        end
      end
    end
    after do
      Object.send(:remove_const, :Rails)
    end
    it 'prints file relative to app path, line number, and literal string object' do
      PutsDebuggererInvoker.static_greeting
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:6 \"Hello World\"\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting("#{name}")
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
    end
  end
  context 'with header support enabled' do
    context 'as default header' do
      before do
        PutsDebuggerer.header = true
      end
      after do
        PutsDebuggerer.header = nil
      end
      it 'prints asterisk header 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
      end
      it 'prints asterisk header 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
      end
      it 'disables header with nil header' do
        PutsDebuggerer.header = nil
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
      end
      it 'disables header with false header' do
        PutsDebuggerer.header = false
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
      end
      it 'disables header with empty string header' do
        PutsDebuggerer.header = ''
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
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
      it 'prints asterisk header 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("#{custom_header}\n[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
      end
      it 'prints asterisk header 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("#{custom_header}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
      end
    end
  end

  context 'with footer support enabled' do
    context 'as default footer' do
      before do
        PutsDebuggerer.footer = true
      end
      after do
        PutsDebuggerer.footer = nil
      end
      it 'prints asterisk footer 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      end
      it 'prints asterisk footer 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      end
      it 'disables footer with nil footer' do
        PutsDebuggerer.footer = nil
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
      end
      it 'disables footer with false footer' do
        PutsDebuggerer.footer = false
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
      end
      it 'disables footer with empty string footer' do
        PutsDebuggerer.footer = ''
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n")
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
      it 'prints asterisk footer 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n#{custom_footer}\n")
      end
      it 'prints asterisk footer 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting("#{name}")
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > (\"Hello \#{name}\").inspect\n  => \"Hello Muhammad\"\n#{custom_footer}\n")
      end
    end
  end


end
