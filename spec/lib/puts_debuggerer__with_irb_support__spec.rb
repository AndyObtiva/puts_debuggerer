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
      expect(output).to eq("[PD] (irb):285\n   > pd 'whoami'\n  => \"whoami\"\n")
    end
  end

end
