require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  
  context 'with run_at specified' do
    context 'as an index' do
      it 'skips first 4 runs, prints on the 5th run, skips 6th and 7th runs' do
        name = 'Robert'
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:5)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)        
        expect(output).to be_empty
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, 5)
        expect(output).to be_empty
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
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:1)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to be_empty
        
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:3)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to be_empty
        
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to be_empty
        
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to be_empty
        
        $stdout = StringIO.new
        output = $stdout.string
        PutsDebuggererInvoker.dynamic_greeting_run_at(name, [1, 3])
        expect(output).to be_empty
      end
    end
    
    context 'as a range' do
      context 'that is finite' do
        it 'skips first 2 runs, prints on 3rd, 4th, 5th, and skips the rest' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          output = $stdout.string
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:3)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:4)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:5)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..5)
          expect(output).to be_empty
        end
      end
      
      context 'that is infinite' do
        it 'skips first 2 runs, prints on the rest' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          output = $stdout.string
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:3)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:4)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:5)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:6)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3..-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:7)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        end
        
        it 'skips first 2 runs, prints on the rest' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          output = $stdout.string
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:3)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:4)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:5)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:6)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 3...-1)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:7)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        end
      end
      
      context 'set as a global option' do
        it 'skips first 2 runs, prints on 3rd, 4th, 5th, and skips the rest' do
          PutsDebuggerer.run_at = 3..5
          expect(PutsDebuggerer.run_at?).to be_truthy
          name = 'Robert'
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          output = $stdout.string
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 (run:3)\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 (run:4)\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 (run:5)\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to be_empty
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to be_empty
        end
      end
      
      describe 'reset' do
        it 'resets the object run at number (counter)' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          output = $stdout.string
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:1)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:2)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to be_empty

          PutsDebuggerer::RunDeterminer.reset_run_at_number("Hello Robert", 1..2)

        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:1)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:2)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to be_empty
        end
        
        it 'resets all object run at numbers (counters)' do
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          output = $stdout.string
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:1)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:2)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to be_empty

          PutsDebuggerer::RunDeterminer.reset_run_at_numbers

        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:1)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:39 (run:2)\n   > pd \"Hello \#{name}\", run_at: run_at\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting_run_at(name, 1..2)
          expect(output).to be_empty
        end
        
        it 'resets global run at counter' do
          PutsDebuggerer.run_at = 1..2
          name = 'Robert'
          PutsDebuggererInvoker.dynamic_greeting(name)
          output = $stdout.string
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 (run:1)\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 (run:2)\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to be_empty

          PutsDebuggerer::RunDeterminer.reset_run_at_global_number

        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 (run:1)\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10 (run:2)\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
        
          $stdout = StringIO.new
          output = $stdout.string
          PutsDebuggererInvoker.dynamic_greeting(name)
          expect(output).to be_empty
        end
      end
    end
  end
end
