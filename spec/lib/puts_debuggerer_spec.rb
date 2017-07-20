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
  it 'prints file, line number, ruby expression, and evaluated string object; returns evaluated object' do
    name = 'Robert'
    expect(PutsDebuggererInvoker.dynamic_greeting(name)).to eq('Hello Robert')
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated string object without extra parentheses when already surrounded; returns evaluated object' do
    name = 'Robert'
    expect(PutsDebuggererInvoker.parentheses_dynamic_greeting(name)).to eq("Hello Robert")
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:14\n   > pd (\"Hello \#{name}\")\n  => \"Hello Robert\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated numeric object without quotes; returns evaluated integer' do
    expect(PutsDebuggererInvoker.numeric_squaring(3)).to eq(9)
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:18\n   > pd n*n\n  => 9\n")
  end
  it 'prints inside pd expression' do
    name = 'Robert'
    expect(PutsDebuggererInvoker.inside_dynamic_greeting(name)).to eq('Hello Robert')
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:35\n   > greeting = \"Hello \#{pd(name)}\"\n  => \"Robert\"\n")
  end

  # TODO remove bad names (like moh') from old repo code via rebase interactive
  # TODO break spec into multiple smaller spec files

  context 'super_method (parent) information inclusion' do
    it 'includes super_method only' # auto-detect if it exists? and have option be true/false/auto?
    it 'includes super_method hierarchy (full)'
    it 'includes super_method hierarchy (at a depth)'
  end


  context 'look into puts debuggerer blog post by tenderlove for other goodies to add'
  context 'deadlock detection support'
  context 'object allocation support' #might need to note having to load this lib first before others for this to work
  context 'support for console.log and/or alert in js'
end
