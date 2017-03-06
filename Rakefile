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
Yes, many of us avoid debuggers like the plague and clamp on to our puts statements like an umbrella in a stormy day. Why not make it official and have puts debugging become its own perfectly legitimate thing?!!

And thus, puts_debuggerer was born. A guilt-free puts debugger Ruby gem FTW!

In other words, puts_debuggerer is a Ruby library for improved puts debugging, automatically displaying bonus useful information such as source line number and source code.

Partially inspired (only partially ;) by this blog post:
https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html
(Credit to Tenderlove.)
  MULTI
  gem.email = "andy.am@gmail.com"
  gem.authors = ["Andy Maleh"]
  gem.files = Dir['lib/**/*.rb']
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
