require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
        
describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  
  before do
    PutsDebuggerer.printer = :puts
    PutsDebuggerer.print_engine = :p  
  end
  
  context 'with return false (do not return object; return string instead)' do
    context 'as default option' do
      it 'prints and returns object by default' do
        object = ['Robert', 40, 1980]
        return_value = PutsDebuggererInvoker.object_with_return_option(object)
        expected_string = "[PD] #{puts_debuggerer_invoker_file}:60\n   > pd object, {}.tap {|h| h.merge!(return: return_option) unless return_option.nil?}\n  => [\"Robert\", 40, 1980]\n"
        output = $stdout.string
        expect(output).to eq(expected_string)
        expect(return_value).to eq(object)      
      end
      
      it 'prints without returning object, yet returning string instead' do
        PutsDebuggerer.return = false
        object = ['Robert', 40, 1980]
        return_value = PutsDebuggererInvoker.object_with_return_option(object)
        expected_string = "[PD] #{puts_debuggerer_invoker_file}:60\n   > pd object, {}.tap {|h| h.merge!(return: return_option) unless return_option.nil?}\n  => [\"Robert\", 40, 1980]\n"
        output = $stdout.string
        expect(output).to eq(expected_string)
        expect(return_value).to eq(expected_string)
      end
      
      it 'prints and returns object when option is specified as true' do
        PutsDebuggerer.return = true
        object = ['Robert', 40, 1980]
        return_value = PutsDebuggererInvoker.object_with_return_option(object)
        expected_string = "[PD] #{puts_debuggerer_invoker_file}:60\n   > pd object, {}.tap {|h| h.merge!(return: return_option) unless return_option.nil?}\n  => [\"Robert\", 40, 1980]\n"
        output = $stdout.string
        expect(output).to eq(expected_string)
        expect(return_value).to eq(object)      
      end
    end
    
    context 'as piecemeal option' do # TODO
      it 'prints and returns object by default' do
        object = ['Robert', 40, 1980]
        return_value = PutsDebuggererInvoker.object_with_return_option(object)
        expected_string = "[PD] #{puts_debuggerer_invoker_file}:60\n   > pd object, {}.tap {|h| h.merge!(return: return_option) unless return_option.nil?}\n  => [\"Robert\", 40, 1980]\n"
        output = $stdout.string
        expect(output).to eq(expected_string)
        expect(return_value).to eq(object)      
      end
      
      it 'prints without returning object, yet returning string instead' do
        object = ['Robert', 40, 1980]
        return_value = PutsDebuggererInvoker.object_with_return_option(object, false)
        expected_string = "[PD] #{puts_debuggerer_invoker_file}:60\n   > pd object, {}.tap {|h| h.merge!(return: return_option) unless return_option.nil?}\n  => [\"Robert\", 40, 1980]\n"
        output = $stdout.string
        expect(output).to eq(expected_string)
        expect(return_value).to eq(expected_string)
      end
      
      it 'prints and returns object when option is specified as true' do
        object = ['Robert', 40, 1980]
        return_value = PutsDebuggererInvoker.object_with_return_option(object, true)
        expected_string = "[PD] #{puts_debuggerer_invoker_file}:60\n   > pd object, {}.tap {|h| h.merge!(return: return_option) unless return_option.nil?}\n  => [\"Robert\", 40, 1980]\n"
        output = $stdout.string
        expect(output).to eq(expected_string)
        expect(return_value).to eq(object)      
      end
    end
  end
end
