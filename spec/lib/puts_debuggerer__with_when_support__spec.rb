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
    PutsDebuggerer.run_at = nil
  end
  after do
    PutsDebuggerer.run_at = nil
  end
  context 'with run_at specified' do
    context 'as an index' do
      after do
        PutsDebuggerer.run_at = nil
      end
      it 'skips first 4 runs, prints on the 5th run, skips 6th and 7th runs' do
        # PutsDebuggerer.run_at = 5
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
      end
      it 'prints 7 times' do
        # PutsDebuggerer.run_at = nil
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, nil)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, nil)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, nil)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, nil)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, nil)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, nil)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, nil)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 7)
      end
    end
    context 'as an array' do

    end
    context 'as a range' do
      context 'finite'
      context 'infinite'
    end
  end
end
