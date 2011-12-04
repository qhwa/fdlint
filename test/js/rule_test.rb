gem 'test-unit'
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'rule/semicolon_test'
require_relative 'rule/stat_if_with_brace_test'
require_relative 'rule/stat_if_with_muti_else_test'
require_relative 'rule/no_eval_test'
require_relative 'rule/use_strict_equal_test'
require_relative 'rule/new_object_and_new_array_test'
require_relative 'rule/nest_try_catch_test'
require_relative 'rule/jq_check_test'

module XRayTest
  
  module JS 

    class RuleTest < Test::Unit::TestSuite

      def self.suite
        tests = Test::Unit::TestSuite.new
        tests << Rule::SemicolonTest.suite
        tests << Rule::StatIfWithBraceTest.suite
        tests << Rule::StatIfWithMutiElseTest.suite
        tests << Rule::NoEvalTest.suite
        tests << Rule::UseStrictEqualTest.suite
        tests << Rule::NewObjectAndNewArrayTest.suite
        tests << Rule::NestTryCatchTest.suite
        tests << Rule::JqCheckTest.suite
        tests
      end
    end
  end
end

Test::Unit::UI::Console::TestRunner.run(XRayTest::JS::RuleTest) if __FILE__ == $0

