gem 'test-unit'
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'rule/check_style_prop_test'
require_relative 'rule/check_unique_import_test'
require_relative 'rule/check_tag_downcase_test'

module XRayTest
  
  module HTML

    class RuleTest < Test::Unit::TestSuite

      def self.suite
        tests = Test::Unit::TestSuite.new
        tests << Rule::CheckStylePropTest.suite
        tests << Rule::CheckUniqueImportTest.suite
        tests << Rule::CheckTagDowncaseTest.suite
        tests
      end
    end
  end
end

Test::Unit::UI::Console::TestRunner.run( XRayTest::HTML::RuleTest ) if __FILE__ == $0

