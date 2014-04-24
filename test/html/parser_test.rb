gem 'test-unit' if defined? gem
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'parser/parse_comment_test'
require_relative 'parser/parse_with_auto_close_tag_test'
require_relative 'parser/parse_with_emtpy_test'
require_relative 'parser/parse_with_multi_children_test'
require_relative 'parser/parse_with_multi_line_test'
require_relative 'parser/parse_with_simple_tag_test'
require_relative 'parser/parse_with_simple_tree_test'
require_relative 'parser/parse_with_selfclosing_test'
require_relative 'parser/parse_with_text_test'
require_relative 'parser/parse_with_prop_test'
require_relative 'parser/parse_with_script_tag_test'
require_relative 'parser/parse_with_style_tag_test'
require_relative 'parser/parse_with_diff_case_test'
require_relative 'parser/parse_dtd_test'
require_relative 'parser/parse_script_tag_test'

module FdlintTest
  
  module HTML

    class ParserTest < Test::Unit::TestSuite

      def self.suite
        Test::Unit::TestSuite.new.tap do |tests|
          tests << Parser::ParseCommentTest.suite
          tests << Parser::ParseWithAutoCloseTagTest.suite
          tests << Parser::ParseWithEmptyTest.suite
          tests << Parser::ParseWithMultiChildrenTest.suite
          tests << Parser::ParseWithMultiLineTest.suite
          tests << Parser::ParseWithSelfClosingTagTest.suite
          tests << Parser::ParseWithSimpleTagTest.suite
          tests << Parser::ParseWithSimpleTreeTest.suite
          tests << Parser::ParsePropertyTest.suite
          tests << Parser::ParseWithTextTest.suite
          tests << Parser::ParseWithScriptTagTest.suite
          tests << Parser::ParseWithStyleTagTest.suite
          tests << Parser::ParseWithDiffCaseTest.suite
          tests << Parser::ParseDTDTest.suite
          tests << Parser::ParseScriptTagTest.suite
        end
      end
    end
  end
end

Test::Unit::UI::Console::TestRunner.run( FdlintTest::HTML::ParserTest ) if __FILE__ == $0

