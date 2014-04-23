unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.expand_path(path.to_str, File.dirname(caller[0]))
    end
  end
end

$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'pathname'
require 'logger'

FIXTURE_ABS_PATH = File.expand_path(File.join( File.dirname(__FILE__) , '/fixtures' ))
FIXTURE_REL_PATH = Pathname.new(FIXTURE_ABS_PATH).relative_path_from(Pathname.new(File.expand_path '.'))
FIXTURE_PATH = FIXTURE_REL_PATH

def has_ruby?(ver)
  not `which ruby#{ver}`.empty?
end

def fixture(path)
  IO.read File.join( FIXTURE_PATH, path )
end

