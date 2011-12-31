gem 'test-unit' if defined? gem
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require File.expand_path('../helper', File.dirname(__FILE__))

module XRayTest
  
  module JS 

    class RuleTest < Test::Unit::TestSuite
      
      NAMES = %w(
        semicolon_test
        stat_if_with_brace_test
        stat_if_with_muti_else_test
        no_eval_test
        use_strict_equal_test
        new_object_and_new_array_test
        nest_try_catch_test
        jq_check_test
        no_global_test
        all_test
        file_checker_test
      )
        
      def self.suite
        tests = Test::Unit::TestSuite.new
        NAMES.each do |name|
          require_relative "rule/#{name}"

          name = name.gsub(/_(\w)/) { |m| m[1].chr.upcase }
          name = name[0].chr.upcase + name[1..-1]

          tests << Rule.const_get(name).suite
        end
        tests
      end
    end
  end
end

Test::Unit::UI::Console::TestRunner.run(XRayTest::JS::RuleTest) if __FILE__ == $0

