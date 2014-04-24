gem 'test-unit' if defined? gem
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'rule/check_style_prop_test'
require_relative 'rule/check_unique_import_test'
require_relative 'rule/check_tag_downcase_test'
require_relative 'rule/check_img_with_alt_prop_test'
require_relative 'rule/check_hyperlink_with_target_test'
require_relative 'rule/check_hyperlink_with_title_test'
require_relative 'rule/check_dtd_test'
require_relative 'rule/check_id_n_class_downcase_test'
require_relative 'rule/check_no_import_css_test'
require_relative 'rule/check_prop_seperator_test'
require_relative 'rule/check_prop_have_value_test'
require_relative 'rule/check_head_contain_meta_and_title_test'
require_relative 'rule/check_block_level_element_test'
require_relative 'rule/check_form_element_name_test'
require_relative 'rule/check_button_test'
require_relative 'rule/check_tag_closed_test'
require_relative 'rule/check_css_in_head_test'
require_relative 'rule/check_unescape_char_test'

module FdlintTest
  
  module HTML

    class RuleTest < Test::Unit::TestSuite

      def self.suite
        tests = Test::Unit::TestSuite.new
        tests << Rule::CheckStylePropTest.suite
        tests << Rule::CheckUniqueImportTest.suite
        tests << Rule::CheckTagDowncaseTest.suite
        tests << Rule::CheckImgWithAltPropTest.suite
        tests << Rule::CheckHyperlinkWithTargetTest.suite
        tests << Rule::CheckHyperlinkWithTitleTest.suite
        tests << Rule::CheckDTDTest.suite
        tests << Rule::CheckIDAndClassPropCaseTest.suite
        tests << Rule::CheckNoCSSImportTest.suite
        tests << Rule::CheckPropSeperatorTest.suite
        tests << Rule::CheckPropHaveValueTest.suite
        tests << Rule::CheckHeadTest.suite
        tests << Rule::CheckBlockLevelElementTest.suite
        tests << Rule::CheckFormElementNameTest.suite
        tests << Rule::CheckButtonTest.suite
        tests << Rule::CheckTagClosedTest.suite
        tests << Rule::CheckCSSInHeadTest.suite
        tests << Rule::CheckUnescapedCharTest.suite
        tests
      end
    end
  end
end

Test::Unit::UI::Console::TestRunner.run( FdlintTest::HTML::RuleTest ) if __FILE__ == $0

