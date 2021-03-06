require 'spec_helper'

describe 'Kernel' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  
  before :all do
    @ruby_engine = RUBY_ENGINE
  end
  
  after :all do
    RUBY_ENGINE = @ruby_engine
    load 'puts_debuggerer/core_ext/kernel.rb'
  end
  
  describe 'caller' do
    it 'returns backtrace' do
      original_caller = caller
      RUBY_ENGINE = 'opal'
      load 'puts_debuggerer/core_ext/kernel.rb'
      expect(caller).to match_array(original_caller)
    end
  end
end
