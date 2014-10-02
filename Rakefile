require 'rake/clean'
require "bundler/gem_tasks"
require 'rubygems'
require 'rubygems/package_task'
require 'fdlint'

spec = eval(File.read('fdlint.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
end

task :default => [:test]

desc 'performance test'
task :perf do
  require 'benchmark'
  #require 'profile'
  js = IO.read('test/fixtures/js/jquery-1.7.js')
  #js = IO.read('test/fixtures/js/scope-test.js').utf8!
  Benchmark.bm do |x|
    x.report("parse jquery-1.7") {
      1.times {
        Fdlint::Parser::JS::JsParser.new(js).parse
      }
    }
  end
end
