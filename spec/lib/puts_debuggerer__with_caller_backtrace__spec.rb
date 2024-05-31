require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}

  context 'with caller backtrace' do
    before do
      PutsDebuggerer.caller = true
    end
    after do
      PutsDebuggerer.caller = nil # defaults to false
    end
    it 'includes full caller backtrace when printing file, line number, ruby expression, and evaluated string object' do
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_caller = (["#{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"] + caller).map {|l| ' '*5 + l}
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 in PutsDebuggererInvoker.dynamic_greeting\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n#{expected_caller.join("\n")}\n")
    end
    it 'includes depth-limited caller backtrace when printing file, line number, ruby expression, and evaluated string object' do
      PutsDebuggerer.caller = 0 # just give me one backtrace entry
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_caller = ["     #{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"]
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 in PutsDebuggererInvoker.dynamic_greeting\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n#{expected_caller.join("\n")}\n")
    end
  end
end
