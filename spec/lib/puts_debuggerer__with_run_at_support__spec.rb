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
    PutsDebuggerer.run_at_global_number = nil
    PutsDebuggerer::OBJECT_RUN_AT.clear
  end
  context 'with run_at specified' do
    after do
      PutsDebuggerer.run_at = nil
      PutsDebuggerer.run_at_global_number = nil
      PutsDebuggerer::OBJECT_RUN_AT.clear
    end
    context 'as an index' do
      it 'skips first 4 runs, prints on the 5th run, skips 6th and 7th runs' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        output = $stdout.string
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
      end
      it 'prints 7 times' do
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
      it 'prints on 1st run, skips 2nd run, prints on 3rd run, skips 6th the rest' do
        name = 'Robert'
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
      end
    end
    context 'as a range' do
      context 'that is finite' do
        it 'skips first 2 runs, prints on 3rd, 4th, 5th, and skips the rest' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          output = $stdout.string
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 3)
        end
        it 'skips first 2 runs, prints on 3rd and 4th, and skips the rest' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...5)
          output = $stdout.string
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...5)
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
        end
      end
      context 'that is infinite' do
        it 'skips first 2 runs, prints on the rest' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          output = $stdout.string
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 4)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 5)
        end
        it 'skips first 2 runs, prints on the rest' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          output = $stdout.string
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 4)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 5)
        end
      end
      context 'set as a global option' do
        it 'skips first 2 runs, prints on 3rd, 4th, 5th, and skips the rest' do
          PutsDebuggerer.run_at = 3..5
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting(name)
          output = $stdout.string
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to be_empty
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 3)
        end
      end
      describe 'reset' do
        it 'resets the object run at number (counter)' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          output = $stdout.string
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)

          PutsDebuggerer.reset_run_at_number("Hello Robert", 1..2)

          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 4)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 4)
        end
        it 'resets all object run at numbers (counters)' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          output = $stdout.string
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 2)

          PutsDebuggerer.reset_run_at_numbers

          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 4)
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n" * 4)
        end
        it 'resets global run at counter' do
          PutsDebuggerer.run_at = 1..2
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting(name)
          output = $stdout.string
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 2)
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 2)

          PutsDebuggerer.reset_run_at_number("Hello Robert", 1..2)

          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 3)
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 4)
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n" * 4)
        end
      end
    end
  end
end
