require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  it 'prints line number in addition to literal string object' do
    output = `
      ruby -e "
        puts_debuggerer_invoker = File.expand_path(File.dirname(__FILE__) + '/spec/support/puts_debuggerer_invoker')
        require puts_debuggerer_invoker
        PutsDebuggererInvoker.static_greeting
      "
    `
    expect(output).to eq("6: \"Hello World\"\n")
  end
  it 'prints line number and ruby expression in addition to evaluated string object' do
    name = 'Muhammad'
    output = `
      ruby -e "
        puts_debuggerer_invoker = File.expand_path(File.dirname(__FILE__) + '/spec/support/puts_debuggerer_invoker')
        require puts_debuggerer_invoker
        PutsDebuggererInvoker.dynamic_greeting('#{name}')
      "
    `
    expect(output).to eq("10: \"Hello \#{name}\".inspect => \"Hello Muhammad\"\n")
  end
end
