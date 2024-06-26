require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}

  context 'irb support' do
    after do
      Object.send(:remove_const, :IRB)
    end
    it 'works' do
      # senseless faking to get irb support to work (tested in IRB as working)
      allow_any_instance_of(Kernel).to receive(:caller) {["(irb):285:in "]*7}
      io = double("io")
      allow(io).to receive(:line).with(285).and_return("pd 'whoami'")
      conf = double("conf", :io => io)
      IRB = Module.new {}
      allow_any_instance_of(Kernel).to receive(:conf) {conf}
      allow_any_instance_of(Kernel).to receive(:__LINE__) {'285'}
      pd 'whoami'
      output = $stdout.string
      expect(output.lines.size).to eq(3)
      expect(output.lines[0]).to match(/\[PD\] \(irb\):285 in RSpec::ExampleGroups::PutsDebuggerer[^:]*::IrbSupport/)
      expect(output.lines[1]).to match(/   > pd 'whoami'/)
      expect(output.lines[2]).to match(/  => \"whoami\"\n/)
    end
    it 'does not utilize IRB when not having conf io (like in MiniTest Rails)' do
      # senseless faking to get irb support to work (tested in IRB as working)
      allow_any_instance_of(Kernel).to receive(:caller) {["(irb):285:in "]*7}
      IRB = Module.new {}
      allow_any_instance_of(Kernel).to receive(:__LINE__) {'285'}
      pd 'whoami'
      output = $stdout.string
      expect(output.lines.size).to eq(3)
      expect(output.lines[0]).to match(/\[PD\] \(irb\):285 in RSpec::ExampleGroups::PutsDebuggerer[^:]*::IrbSupport/)
      expect(output.lines[1]).to match(/   > /)
      expect(output.lines[2]).to match(/  => \"whoami\"/)
    end
  end

end
