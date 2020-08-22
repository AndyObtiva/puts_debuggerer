require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PutsDebuggerer' do
  let(:puts_debuggerer_invoker_file) {File.expand_path(File.join(__FILE__, '..', '..', 'support', 'puts_debuggerer_invoker.rb'))}
  context 'with rails' do
    before do
      load "awesome_print/core_ext/kernel.rb"
      @awesome_print_defaults = AwesomePrint.defaults
      AwesomePrint.defaults = {
        plain: true
      }
      Kernel.send(:remove_method, :ap) rescue nil
      Object.class_eval do
        module Rails
          class Logger
            def debug(object)
              # simulate a Rails logger. Adding extra prefix to ease testing.
              puts "Rails.logger.debug: #{object.inspect}"
            end
            def ap(object)
              # simulate a Rails ap logger. Adding extra prefix to ease testing.
              print "Rails.logger.ap:"
              Object.send(:ap, object)
            end
          end
          def self.root
            File.expand_path(File.join(__FILE__, '..', '..', '..'))
          end
          def self.logger
            @logger ||= Logger.new
          end
        end
      end
      PutsDebuggerer.app_path = nil # defaults to Rails
      PutsDebuggerer.print_engine = :p
    end
    after do
      Object.send(:remove_const, :Rails)
      PutsDebuggerer.app_path = nil # default app_path
      Kernel.send(:remove_method, :ap) rescue nil
      AwesomePrint.defaults = @awesome_print_defaults
    end
    it 'prints file relative to app path, line number, ruby expression, and evaluated string object' do
      name = 'Robert'
      PutsDebuggererInvoker.dynamic_greeting(name)
      output = $stdout.string
      expect(output).to eq("[PD] /spec/support/puts_debuggerer_invoker.rb:10\n   > pd \"Hello \#{name}\"\n  => \"Hello Robert\"\n")
    end
    it 'defaults to Rails awesome_print logger in Rails app with awesome_print' do
      load "awesome_print/core_ext/kernel.rb"
      PutsDebuggerer.print_engine = nil
      PutsDebuggererInvoker.static_nested_array
      output = $stdout.string
      expect(output).to eq(<<-MULTILINE
[PD] /spec/support/puts_debuggerer_invoker.rb:22
   > pd [1, [2, 3]]
  => [
    [0] 1,
    [1] [
        [0] 2,
        [1] 3
    ]
]
      MULTILINE
      )
    end
  end
end
