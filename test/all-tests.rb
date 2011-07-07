require 'test/unit'
gem 'test-unit'
require 'test/unit/testsuite'

require_relative 'parser_visitable_test'
require_relative 'position_info_test'
require_relative 'css/parser_test'
require_relative 'css/rule/check_list_rule_test'

module XRayTest
    
    class ALL < Test::Unit::TestSuite

        def self.suite
            tests = []
            tests << PositionInfoTest.new
            tests << ParserVisitableTest.new
            tests << CSS::ParserTest.new
            tests << CSS::Rule::CheckListRuleTest.new
            tests
        end
    end

end
