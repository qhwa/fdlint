require 'rake/clean'
require "bundler/gem_tasks"
require 'rubygems'
require 'rubygems/package_task'

spec = eval(File.read('fdlint.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
end

task :default => [:test]
