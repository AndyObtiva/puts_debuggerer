require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  before do
    $stdout = StringIO.new
  end
  it 'prints line number in addition to literal string object' do
    puts_debuggerer_invoker = File.expand_path(File.dirname(__FILE__) + '/spec/support/puts_debuggerer_invoker')
    PutsDebuggererInvoker.static_greeting
    output = $stdout.string
    expect(output).to eq("6: \"Hello World\"\n")
  end
  it 'prints line number and ruby expression in addition to evaluated string object' do
    name = 'Muhammad'
    puts_debuggerer_invoker = File.expand_path(File.dirname(__FILE__) + '/spec/support/puts_debuggerer_invoker')
    PutsDebuggererInvoker.dynamic_greeting("#{name}")
    output = $stdout.string
    expect(output).to eq("10: \"Hello \#{name}\".inspect => \"Hello Muhammad\"\n")
  end
end
