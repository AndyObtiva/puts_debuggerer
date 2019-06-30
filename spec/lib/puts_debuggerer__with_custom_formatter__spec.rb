require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  before do
    $stdout = StringIO.new
    PutsDebuggerer.printer = :puts
    PutsDebuggerer.print_engine = :p
    PutsDebuggerer.formatter = nil
    PutsDebuggerer.header = nil
    PutsDebuggerer.footer = nil
    PutsDebuggerer.caller = nil
    PutsDebuggerer.app_path = nil
  end
  context 'with custom formatter' do
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
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_output = <<-MULTI
-<[PD]>-
HEADER: #{'*'*80}
FILE: #{puts_debuggerer_invoker_file}
LINE: 10
EXPRESSION: pd "Hello \#{name}"
PRINT OUT: "Hello Robert"
CALLER: #{__FILE__}:#{__LINE__-9}:in `block (3 levels) in <top (required)>'
FOOTER: #{'*'*80}
      MULTI
      expect(output).to eq(expected_output)
    end
    it 'resets format' do
      PutsDebuggerer.formatter = nil
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expected_caller = "     #{__FILE__}:#{__LINE__-2}:in `block (3 levels) in <top (required)>'"
      expect(output).to eq("#{PutsDebuggerer::HEADER_DEFAULT}\n[PD] #{puts_debuggerer_invoker_file}:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n#{expected_caller}\n#{PutsDebuggerer::FOOTER_DEFAULT}\n")
    end
    #TODO support formatting header, footer, and caller backtrace too
  end
end
