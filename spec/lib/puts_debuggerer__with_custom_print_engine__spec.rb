require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}

  context 'with custom print engine' do
    let(:expected_object_printout) {
      "[\n    [0] 1,\n    [1] [\n        [0] 2,\n        [1] 3\n    ]\n]"
    }
    let(:expected_object_printout_indent2) {
      "[\n    [0] 1,\n    [1] [\n        [0] 2,\n        [1] 3\n    ]\n]"
    }
    before do
      load "awesome_print/core_ext/kernel.rb"
      @awesome_print_defaults = AwesomePrint.defaults
      AwesomePrint.defaults = {
        plain: true
      }
      Kernel.class_eval do
        def print_meh(object)
          puts "Meh! #{object}"
        end
      end
      PutsDebuggerer.print_engine = nil #auto detect awesome_print
    end
    after do
      AwesomePrint.defaults = @awesome_print_defaults
      Kernel.send(:remove_method, :print_meh) rescue nil
      Kernel.send(:remove_method, :ap) rescue nil
    end
    it 'prints using passed in custom lambda print engine' do
      PutsDebuggerer.print_engine = lambda {|text| puts "**\"#{text}\"**"} #intentionally set as :p
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => **\"Hello Robert\"**\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      PutsDebuggererInvoker.static_nested_array
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:22\n   > pd [1, [2, 3]]\n  => #{expected_object_printout}\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => #{expected_object_printout}\n")
    end
    it 'raises informative error if print_engine was invalid' do
      expect {PutsDebuggerer.print_engine = :invalid}.to raise_error('print_engine must be a valid global method symbol (e.g. :p, :ap or :pp) or lambda/proc receiving an object arg')
    end
    it 'supports passing extra options to print_engines like awesome_print' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], indent: 2)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => #{expected_object_printout_indent2}\n")
    end
    it 'ignores extra options with print_engines not supporting them' do
      PutsDebuggerer.print_engine = :print_meh
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], indent: 2)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => Meh! [1, [2, 3]]\n")
    end
  end

end
