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
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], header: true)
      output = $stdout.string
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling footer per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], footer: true)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling both header and footer per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], header: '#'*80, footer: true)
      output = $stdout.string
      expect(output).to eq("#{'#'*80}\n[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching print engine per single puts' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], print_engine: :ap)
      output = $stdout.string
      expected_object_printout = "[\n    [0] 1,\n    [1] [\n        [0] 2,\n        [1] 3\n    ]\n]"
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => #{expected_object_printout}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching app path per single puts' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], app_path: app_path)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file.sub(app_path, '')}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
    end
    it 'supports switching announcer per single puts' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], announcer: "!!!!!HELLO!!!!!")
      output = $stdout.string
      expect(output).to eq("!!!!!HELLO!!!!! #{puts_debuggerer_invoker_file.sub(app_path, '')}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
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
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
    end
    it 'supports enabling caller per single puts' do
      app_path = File.expand_path(File.join(__FILE__, '..'))
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]], caller: 0)
      output = $stdout.string
      expected_caller = ["     #{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"]
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n#{expected_caller.join("\n")}\n")
      $stdout = StringIO.new
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => [1, [2, 3]]\n")
    end
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
