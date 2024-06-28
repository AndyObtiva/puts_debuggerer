require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  
  it 'prints file, line number, ruby expression, and evaluated string object; returns evaluated object' do
    name = 'Robert'
    expect(PutsDebuggererInvoker.dynamic_greeting(name)).to eq('Hello Robert')
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 in PutsDebuggererInvoker.dynamic_greeting\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
  end
  
  it 'prints file, line number, ruby expression, and evaluated string object without extra parentheses when already surrounded; returns evaluated object' do
    name = 'Robert'
    expect(PutsDebuggererInvoker.parentheses_dynamic_greeting(name)).to eq("Hello Robert")
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:14 in PutsDebuggererInvoker.parentheses_dynamic_greeting\n   > pd (\"Hello \#{name}\")\n  => \"Hello Robert\"\n")
  end
  
  it 'prints file, line number, ruby expression, and evaluated numeric object without quotes; returns evaluated integer' do
    expect(PutsDebuggererInvoker.numeric_squaring(3)).to eq(9)
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:18 in PutsDebuggererInvoker.numeric_squaring\n   > pd n*n\n  => 9\n")
  end
  
  it 'prints inside pd expression' do
    name = 'Robert'
    expect(PutsDebuggererInvoker.inside_dynamic_greeting(name)).to eq('Hello Robert')
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:35 in PutsDebuggererInvoker.inside_dynamic_greeting\n   > greeting = \"Hello \#{pd(name)}\"\n  => \"Robert\"\n")
  end

  it 'prints exception stack trace' do
    class FakeException < Exception
      def full_message
        <<~MULTI_LINE_STRING
          stack trace line 1
          stack trace line 2
          stack trace line 3
        MULTI_LINE_STRING
      end
    end
    e = FakeException.new
    PutsDebuggererInvoker.exception_stack_trace(e)
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:48 in PutsDebuggererInvoker.exception_stack_trace\n   > pd error\n  => stack trace line 1\nstack trace line 2\nstack trace line 3\n")
  end
  
  it 'prints *args array' do
    result = PutsDebuggererInvoker.vararg_array
    expect(result).to eq(['hello', 3, true])
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:52 in PutsDebuggererInvoker.vararg_array\n   > pd 'hello', 3, true\n  => [\"hello\", 3, true]\n")
  end

  it 'prints *args array with options at the end' do
    result = PutsDebuggererInvoker.vararg_array_with_options(wrapper: true)
    expect(result).to eq(['hello', 3, true])
    output = $stdout.string
    expect(output).to eq("********************************************************************************\n[PD] #{puts_debuggerer_invoker_file}:56 in PutsDebuggererInvoker.vararg_array_with_options\n   > pd 'hello', 3, true, options\n  => [\"hello\", 3, true]\n********************************************************************************\n")
  end

  it 'prints using pd_inspect' do
    result = PutsDebuggererInvoker.call_pd_inspect([1, [2, [3]]])
    # TODO it is odd we are getting the PutsDebuggerInvoker file, but the Array class. See if we should fix something here.
    expect(result).to eq("[PD] #{puts_debuggerer_invoker_file}:68 in Array.call_pd_inspect\n   > object.pd_inspect\n  => [1, [2, [3]]]\n")
    output = $stdout.string
    expect(output).to eq("")
  end
  
  it 'prints frozen hash' do
    hash = {a: 1, b: 2, c: 3, h: :t, f: :t}.freeze
    result = PutsDebuggererInvoker.call_pd(hash)
    # TODO it is odd we are getting the PutsDebuggerInvoker file, but the Array class. See if we should fix something here.
    expect(result).to eq(hash)
    output = $stdout.string
    expect(output).to eq(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[PD] /Users/andymaleh/code/puts_debuggerer/spec/support/puts_debuggerer_invoker.rb:60 in PutsDebuggererInvoker.call_pd\n   > pd *args\n  => {:a=>1, :b=>2, :c=>3, :h=>:t, :f=>:t}\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n")
  end

  context 'look into puts debuggerer blog post by tenderlove for other goodies to add'
  context 'deadlock detection support'
  context 'object allocation support' #might need to note having to load this lib first before others for this to work
  context 'support for console.log and/or alert in js'
end
