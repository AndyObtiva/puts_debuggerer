require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  context 'with piecemeal options' do
    before do
      load "awesome_print/core_ext/kernel.rb"
      @awesome_print_defaults = AwesomePrint.defaults
      AwesomePrint.defaults = {
        plain: true
      }
    end
    after do
      AwesomePrint.defaults = @awesome_print_defaults
      Kernel.send(:remove_method, :ap)
    end
    it 'supports enabling header per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array(header: true) # support options alone
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:header=>true}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], header: true)
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array(name: 'Sean', header: true) # support hash including options
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:name=>\"Sean\", :header=>true}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling header per single puts using shortcut syntax' do
      PutsDebuggererInvoker.dynamic_nested_array(h: :t) # support options alone
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:h=>:t}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], h: :t)
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array(name: 'Sean', h: :t) # support hash including options
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:name=>\"Sean\", :h=>:t}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling footer per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array(footer: true) # support options alone
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:footer=>true}\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], footer: true)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array(name: 'Sean', footer: true) # support hash including options
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:name=>\"Sean\", :footer=>true}\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling footer per single puts using shortcut syntax' do
      PutsDebuggererInvoker.dynamic_nested_array(f: :t) # support options alone
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:f=>:t}\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], f: :t)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array(name: 'Sean', f: :t) # support hash including options
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => {:name=>\"Sean\", :f=>:t}\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling both header and footer per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], header: '#'*80, footer: true)
      output = $stdout.string
      expect(output).to eq("#{'#'*80}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling wrapper per single puts using shortcut syntax' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], w: :t)
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::WRAPPER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n#{PutsDebuggerer::WRAPPER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching printer per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], printer: lambda {|output| puts output.upcase})
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file.upcase}:26 IN PUTSDEBUGGERERINVOKER.DYNAMIC_NESTED_ARRAY\n   > PD *ARRAY_INCLUDING_OPTIONS\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching print engine per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], print_engine: :ap)
      output = $stdout.string
      expected_object_printout = "[\n    [0] 1,\n    [1] [\n        [0] 2,\n        [1] 3\n    ]\n]"
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => #{expected_object_printout}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching app path per single puts' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], app_path: app_path)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file.sub(app_path, '')}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching announcer per single puts' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], announcer: "!!!!!HELLO!!!!!")
      output = $stdout.string
      expect(output).to eq("!!!!!HELLO!!!!! #{puts_debuggerer_invoker_file.sub(app_path, '')}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching announcer per single puts with shortcut syntax' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], a: "!!!!!HELLO!!!!!")
      output = $stdout.string
      expect(output).to eq("!!!!!HELLO!!!!! #{puts_debuggerer_invoker_file.sub(app_path, '')}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching formatter per single puts' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], formatter: -> (data) {
        print "#{data[:announcer]}:#{data[:line_number]}:"
        data[:object_printer].call
      })
      output = $stdout.string
      expect(output).to eq("[PD]:26:[1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling caller per single puts' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], caller: 0)
      output = $stdout.string
      expected_caller = ["     #{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"]
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n#{expected_caller.join("\n")}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling caller per single puts with shortcut syntax' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], c: 0)
      output = $stdout.string
      expected_caller = ["     #{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"]
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n#{expected_caller.join("\n")}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26 in PutsDebuggererInvoker.dynamic_nested_array\n   > pd *array_including_options\n  => [1, [2, 3]]\n")
    end
  end
end
