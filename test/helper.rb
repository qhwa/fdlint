unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.expand_path(path.to_str, File.dirname(caller[0]))
    end
  end
end

$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'node'
require 'log_entry.rb'
require 'runner'
require 'pathname'
require 'logger'

FIXTURE_ABS_PATH = File.expand_path(File.join( File.dirname(__FILE__) , '/fixtures' ))
FIXTURE_REL_PATH = Pathname.new(FIXTURE_ABS_PATH).relative_path_from(Pathname.new(File.expand_path '.'))
FIXTURE_PATH = FIXTURE_REL_PATH


module XRayTest
  class Logger < ::Logger
    def initialize
      super(STDOUT)
      debug = ARGV.include? '-d'
      self.level = debug ? Logger::INFO : Logger::WARN
    end 
  end
end

