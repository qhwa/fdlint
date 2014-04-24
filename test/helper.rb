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

require 'fdlint'

FIXTURE_ABS_PATH = File.expand_path(File.join( File.dirname(__FILE__) , '/fixtures' ))
FIXTURE_REL_PATH = Pathname.new(FIXTURE_ABS_PATH).relative_path_from(Pathname.new(File.expand_path '.'))
FIXTURE_PATH = FIXTURE_REL_PATH

def has_ruby?(ver)
  not `which ruby#{ver}`.empty?
end

def fixture(path)
  IO.read fixture_path( path )
end

def fixture_path( path )
  File.join( FIXTURE_PATH, path )
end

def assert_has_result( results, condition, msg=nil)
  level, text = *condition
  assert(
    results.index do |ret|
      ret.level == level && ret.message == text
    end,
    msg
  )
end

def assert_not_has_result( results, condition, msg=nil)
  level, text = *condition
  assert_nil(
    results.index do |ret|
      ret.level == level && ret.message == text
    end,
    msg
  )
end

module FdlintTest

  module RuleTest

    def self.extended(klass)
      def klass.included(cls)
        cls.send :include, FdlintTest::RuleTest
      end
    end

    def self.included(klass)
      klass.send :extend,  ClassMethods
      klass.send :include, InstanceMethods
    end

    module ClassMethods

      def check_rule expect, &block
        @expect = expect
        yield
      end

      def should_with_result expect=@expect, &block
        level, msg = *expect
        texts(&block).each_with_index do |src, i|
          define_method "test_should_with_result_#{msg}_#{i}_#{src[0,20]}" do
            parse src do |results|
              assert_has_result results, expect, msg
            end
          end
        end
      end

      def should_without_result expect=@expect, &block
        level, msg = *expect
        texts(&block).each_with_index do |src, i|
          define_method "test_should_without_result_#{msg}_#{i}" do
            parse src do |results|
              assert_not_has_result results, expect, msg
            end
          end
        end
      end

      def texts( &block )
        texts = block.call
        texts = [texts] if texts.is_a? String
        texts
      end
    end

    module InstanceMethods
      def parse text, &block
        Fdlint::Validator.new( nil, :text => text, :syntax => syntax ).validate.tap do |results|
          yield results if block_given?
        end
      end
    end

  end

  module HTML
    include Fdlint::Parser::HTML
    extend FdlintTest::RuleTest

    def parser( text )
      @parser ||= HtmlParser.new(text)
    end
    
    def syntax
      :html
    end

  end

  module JS
    include Fdlint::Parser::JS
    extend FdlintTest::RuleTest

    def parser( text )
      @parser ||= JsParser.new(text)
    end

    def syntax
      :js
    end
    
  end
end
