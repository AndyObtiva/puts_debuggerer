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
  it 'prints file, line number, and literal string object' do
    PutsDebuggererInvoker.static_greeting
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated string object' do
    name = 'Muhammad'
    PutsDebuggererInvoker.dynamic_greeting(name)
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated string object without extra parentheses when already surrounded' do
    name = 'Muhammad'
    PutsDebuggererInvoker.parentheses_dynamic_greeting(name)
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:14\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
  end
  it 'prints file, line number, ruby expression, and evaluated numeric object without quotes' do
    PutsDebuggererInvoker.numeric_squaring(3)
    output = $stdout.string
    expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:18\n   > pd n*n\n  => 9\n")
  end
  context 'with app path provided' do
    before do
      PutsDebuggerer.app_path = File.expand_path(__FILE__).sub(/spec\/lib\/puts_debuggerer_spec.rb$/, '')
    end
    after do
      PutsDebuggerer.app_path = nil
    end
    it 'prints file relative to app path, line number, and literal string object' do
      PutsDebuggererInvoker.static_greeting
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:6 \"Hello World\"\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
    end
  end
  context 'with rails' do
    before do
      Object.class_eval do
        module Rails
          def self.root
            File.expand_path(__FILE__).sub(/spec\/lib\/puts_debuggerer_spec.rb$/, '')
          end
        end
      end
      PutsDebuggerer.app_path = nil # defaults to Rails
    end
    after do
      Object.send(:remove_const, :Rails)
      PutsDebuggerer.app_path = nil # default app_path
    end
    it 'prints file relative to app path, line number, and literal string object' do
      PutsDebuggererInvoker.static_greeting
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:6 \"Hello World\"\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] spec/support/puts_debuggerer_invoker.rb:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
    end
  end
  context 'with header support enabled' do
    context 'as default header' do
      before do
        PutsDebuggerer.header = true
      end
      after do
        PutsDebuggerer.header = nil
      end
      it 'prints asterisk header 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
      end
      it 'prints asterisk header 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
      it 'disables header with nil header' do
        PutsDebuggerer.header = nil
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
      it 'disables header with false header' do
        PutsDebuggerer.header = false
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
      it 'disables header with empty string header' do
        PutsDebuggerer.header = ''
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
    end
    context 'as custom header' do
      let(:custom_header) {'>>>PRINT OUT<<<'}
      before do
        PutsDebuggerer.header = custom_header
      end
      after do
        PutsDebuggerer.header = nil
      end
      it 'prints asterisk header 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("#{custom_header}\n[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
      end
      it 'prints asterisk header 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("#{custom_header}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
    end
  end

  context 'with footer support enabled' do
    context 'as default footer' do
      before do
        PutsDebuggerer.footer = true
      end
      after do
        PutsDebuggerer.footer = nil
      end
      it 'prints asterisk footer 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      end
      it 'prints asterisk footer 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
      end
      it 'disables footer with nil footer' do
        PutsDebuggerer.footer = nil
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
      it 'disables footer with false footer' do
        PutsDebuggerer.footer = false
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
      it 'disables footer with empty string footer' do
        PutsDebuggerer.footer = ''
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n")
      end
    end
    context 'as custom footer' do
      let(:custom_footer) {'>>>PRINT OUT<<<'}
      before do
        PutsDebuggerer.footer = custom_footer
      end
      after do
        PutsDebuggerer.footer = nil
      end
      it 'prints asterisk footer 80 times by default before static PD print out' do
        PutsDebuggererInvoker.static_greeting
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n#{custom_footer}\n")
      end
      it 'prints asterisk footer 80 times by default before dynamic PD print out' do
        name = 'Muhammad'
        PutsDebuggererInvoker.dynamic_greeting(name)
        output = $stdout.string
        expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n#{custom_footer}\n")
      end
    end
  end

  context 'with custom print engine' do
    let(:expected_object_printout) {
      "[\n    [0] 1,\n    [1] [\n        [0] 2,\n        [1] 3\n    ]\n]"
    }
    let(:expected_object_printout_indent2) {
      "[\n  [0] 1,\n  [1] [\n    [0] 2,\n    [1] 3\n  ]\n]"
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
      PutsDebuggerer.print_engine = :p
      AwesomePrint.defaults = @awesome_print_defaults
      Kernel.send(:remove_method, :print_meh)
      Kernel.send(:remove_method, :ap)
    end
    it 'defaults to :p print engine if awesome_print not loaded, auto-detects and wires awesome_print as default if loaded' do
      Kernel.send(:remove_method, :ap)
      PutsDebuggerer.print_engine = nil #intentionally set as :p
      expect(PutsDebuggerer.print_engine).to eq(:p)
      load "awesome_print/core_ext/kernel.rb"
      PutsDebuggerer.print_engine = nil #reset to default
      expect(PutsDebuggerer.print_engine).to eq(:ap)
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      PutsDebuggererInvoker.static_nested_array
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:22 #{expected_object_printout}\n")
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      PutsDebuggererInvoker.dynamic_nested_array([1, [2, 3]])
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:26\n   > pd array, options\n  => #{expected_object_printout}\n")
    end
    it 'raises informative error if print_engine was invalid' do
      expect {PutsDebuggerer.print_engine = :invalid}.to raise_error('print_engine must be a valid global method symbol (e.g. :p or :puts)')
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

  context 'with custom announcer' do
    let(:custom_announcer) {'<PD>'}
    before do
      PutsDebuggerer.announcer = custom_announcer
    end
    after do
      PutsDebuggerer.announcer = nil
    end
    it 'changes [PD] to <PD>' do
      PutsDebuggererInvoker.static_greeting
      output = $stdout.string
      expect(output).to eq("<PD> #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
    end
    it 'resets to default announcer when announcer is set to nil' do
      PutsDebuggerer.announcer = nil
      PutsDebuggererInvoker.static_greeting
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n")
    end
  end

  context 'irb support' do
    it 'works' do
      # senseless faking to get irb support to work (tested in IRB as working)
      allow_any_instance_of(Kernel).to receive(:caller) {["(irb):285:in "]*7}
      io = double("io")
      allow(io).to receive(:line).with(285).and_return("pd 'whoami'")
      conf = double("conf", :io => io)
      allow_any_instance_of(Kernel).to receive(:conf) {conf}
      allow_any_instance_of(Kernel).to receive(:__LINE__) {'285'}
      pd 'whoami'
      output = $stdout.string
      expect(output).to eq("[PD] (irb):285 \"whoami\"\n")
    end
  end

  context 'with custom format' do
    before do
      PutsDebuggerer.header = true
      PutsDebuggerer.footer = true
      PutsDebuggerer.caller = 0
      PutsDebuggerer.formatter = -> (data) {
        puts "-<#{data[:announcer]}>-"
        puts "HEADER: #{data[:header]}"
        puts "FILE: #{data[:file]}"
        puts "LINE: #{data[:line_number]}"
        puts "EXPRESSION: #{data[:pd_expression]}"
        print "PRINT OUT: "
        data[:object_printer].call
        puts "CALLER: #{data[:caller].to_a.first}"
        puts "FOOTER: #{data[:footer]}"
      }
    end
    after do
      PutsDebuggerer.formatter = nil
      PutsDebuggerer.header = nil
      PutsDebuggerer.footer = nil
      PutsDebuggerer.caller = nil
    end
    it 'prints custom format' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_output = <<-MULTI
-<[PD]>-
HEADER: #{'*'*80}
FILE: #{puts_debuggerer_invoker_file}
LINE: 10
EXPRESSION: "Hello \#{name}"
PRINT OUT: "Hello Muhammad"
CALLER: #{__FILE__}:#{__LINE__-9}:in `block (3 levels) in <top (required)>'
FOOTER: #{'*'*80}
      MULTI
      expect(output).to eq(expected_output)
    end
    it 'resets format' do
      PutsDebuggerer.formatter = nil
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_caller = "     #{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n#{expected_caller}\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
    end
    #TODO support formatting header, footer, and caller backtrace too
  end

  context 'exception cases' do
    it 'handles multi line ruby expressions correctly' do
      name = 'Muhammad'
      PutsDebuggererInvoker.multi_line_dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:30\n   > pd \"Hello \" +\n      name.to_s\n  => \"Hello Muhammad\"\n")
    end
  end

  context 'with caller backtrace' do
    before do
      PutsDebuggerer.caller = true
    end
    after do
      PutsDebuggerer.caller = nil # defaults to false
    end
    it 'includes full caller backtrace when printing file, line number, and literal string object' do
      PutsDebuggererInvoker.static_greeting
      output = $stdout.string
      expected_caller = (["#{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"] + caller).map {|l| ' '*5 + l}
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:6 \"Hello World\"\n#{expected_caller.join("\n")}\n")
    end
    it 'includes full caller backtrace when printing file, line number, ruby expression, and evaluated string object' do
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_caller = (["#{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"] + caller).map {|l| ' '*5 + l}
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n#{expected_caller.join("\n")}\n")
    end
    it 'includes depth-limited caller backtrace when printing file, line number, ruby expression, and evaluated string object' do
      PutsDebuggerer.caller = 0 # just give me one backtrace entry
      name = 'Muhammad'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_caller = ["     #{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"]
      expect(output).to eq("[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Muhammad\"\n#{expected_caller.join("\n")}\n")
    end
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
end
