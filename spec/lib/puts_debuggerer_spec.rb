require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  before do
    $stdout = StringIO.new
  end
  it 'prints file, line number, and literal string object' do
    PutsDebuggererInvoker.static_greeting
    output = $stdout.string
    expect(output).to eq("pd /Users/User/code/puts_debuggerer/spec/support/puts_debuggerer_invoker.rb:6 \"Hello World\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated string object' do
    name = 'Muhammad'
    PutsDebuggererInvoker.dynamic_greeting("#{name}")
    output = $stdout.string
    expect(output).to eq("pd /Users/User/code/puts_debuggerer/spec/support/puts_debuggerer_invoker.rb:10 \"Hello \#{name}\".inspect => \"Hello Muhammad\"\n")
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
      expect(output).to eq("pd spec/support/puts_debuggerer_invoker.rb:6 \"Hello World\"\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting("#{name}")
      output = $stdout.string
      expect(output).to eq("pd spec/support/puts_debuggerer_invoker.rb:10 \"Hello \#{name}\".inspect => \"Hello Muhammad\"\n")
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
      expect(output).to eq("pd spec/support/puts_debuggerer_invoker.rb:6 \"Hello World\"\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting("#{name}")
      output = $stdout.string
      expect(output).to eq("pd spec/support/puts_debuggerer_invoker.rb:10 \"Hello \#{name}\".inspect => \"Hello Muhammad\"\n")
    end
  end
end
