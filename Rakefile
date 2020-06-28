# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "puts_debuggerer"
  gem.homepage = "http://github.com/AndyObtiva/puts_debuggerer"
  gem.license = "MIT"
  gem.summary = %Q{Ruby library for improved puts debugging, automatically displaying bonus useful information such as source line number and source code.}
  gem.description = <<-MULTI
Debuggers are great! They help us troubleshoot complicated programming problems by inspecting values produced by code, line by line. They are invaluable when trying to understand what is going on in a large application composed of thousands or millions of lines of code.
In day-to-day test-driven development and simple debugging though, a puts statement can be a lot quicker in revealing what is going on than halting execution completely just to inspect a single value or a few. This is certainly true when writing the simplest possible code that could possibly work, and running a test every few seconds or minutes. Problem is you need to locate puts statements in large output logs, know which methods were invoked, find out what variable names are being printed, and see nicely formatted output. Enter puts_debuggerer. A guilt-free puts debugging Ruby gem FTW that prints file names, line numbers, code statements, and formats output nicely courtesy of awesome_print.
Partially inspired by this blog post: https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html (Credit to Tenderlove.)
  MULTI
  gem.email = "andy.am@gmail.com"
  gem.authors = ["Andy Maleh"]
  gem.files = Dir['VERSION', 'LICENSE.txt', 'README.md', 'lib/**/*.rb']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "puts_debuggerer #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
