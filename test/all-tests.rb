gem 'test-unit' if defined? gem
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.expand_path(path.to_str, File.dirname(caller[0]))
    end
  end
end

require_relative 'parser_visitable_test'
require_relative 'position_info_test'
require_relative 'css/parser_test'
require_relative 'css/mac_line_end_support_test'
require_relative 'css/rule/check_list_rule_test'
require_relative 'css/rule/check_encoding_test'
require_relative 'css/rule/file_name_test'
require_relative 'css/rule/compression_test'
require_relative 'html/parser_test'
require_relative 'html/rule_test'
require_relative 'html/query_test'
require_relative 'js/parser_test'
require_relative 'js/rule_test'
require_relative 'rule_dsl/dsl_basic_test'


module XRayTest

  class ALL < Test::Unit::TestSuite

    def self.suite
      tests = Test::Unit::TestSuite.new

      tests << PositionInfoTest.suite
      tests << ParserVisitableTest.suite
      
      #CSS
      tests << CSS::ParserTest.suite
      tests << CSS::MacLineEndSupportTest.suite
      tests << CSS::Rule::CheckListRuleTest.suite
      tests << CSS::Rule::CheckEncodingTest.suite
      tests << CSS::Rule::CheckFileNameTest.suite
      tests << CSS::Rule::CompressionTest.suite

      #HTML
      tests << HTML::ParserTest.suite
      tests << HTML::RuleTest.suite
      tests << HTML::QueryTest.suite

      #JS
      tests << JS::ParserTest.suite
      tests << JS::RuleTest.suite

      #RULE
      tests << Rule::DSLBasicTest.suite

      tests
    end
  end

end

Test::Unit::UI::Console::TestRunner.run( XRayTest::ALL )
