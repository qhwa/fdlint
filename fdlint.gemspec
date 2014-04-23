# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','fdlint','version.rb'])
spec = Gem::Specification.new do |s| 

  s.name             = "fdlint"
  s.version          = Fdlint::VERSION
  s.summary          = "Code reviewer for web developing. Check your HTML/JS/CSS codes against bad codes."
  s.author           = "qhwa,bencode"
  s.email            = "qhwa@163.com,bencode@163.com"
  s.homepage         = "https://github.com/qhwa/fdlint"
  s.has_rdoc         = false
  s.extra_rdoc_files = %w(README.md)
  s.rdoc_options     = %w(--main README.md)
  s.files            = %w(README.md Rakefile Gemfile.lock Gemfile) +
                        Dir.glob("{bin,test,lib,rules.d}/**/*") -
                        Dir.glob("test/fixtures/html/{cms,tmp}/**/*")

  s.require_paths << 'lib'
  s.executables << 'fdlint'
  s.has_rdoc = false
  s.bindir   = 'bin'

  s.add_runtime_dependency('gli','~> 2.9.0')
  s.add_runtime_dependency("colored", "~> 1.2")
  s.add_runtime_dependency("string_utf8", "~> 0.1.1")

  s.add_development_dependency("rake", "~> 0.9.2.2")
  s.add_development_dependency("test-unit")
  s.add_development_dependency("bundler")

end
