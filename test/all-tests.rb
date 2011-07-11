gem 'test-unit'
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'parser_visitable_test'
require_relative 'position_info_test'
require_relative 'css/parser_test'
require_relative 'css/mac_line_end_support_test'
require_relative 'css/rule/check_list_rule_test'
require_relative 'css/rule/check_encoding_test'
require_relative 'css/rule/file_name_test'

module XRayTest

  class ALL < Test::Unit::TestSuite

    def self.suite
      tests = Test::Unit::TestSuite.new
      tests << PositionInfoTest.suite
      tests << ParserVisitableTest.suite
      tests << CSS::ParserTest.suite
      tests << CSS::MacLineEndSupportTest.suite
      tests << CSS::Rule::CheckListRuleTest.suite
      tests << CSS::Rule::CheckEncodingTest.suite
      tests << CSS::Rule::CheckFileNameTest.suite
      tests
    end
  end

end

Test::Unit::UI::Console::TestRunner.run( XRayTest::ALL )
