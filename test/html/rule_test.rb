gem 'test-unit'
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

module XRayTest
  
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
        tests
      end
    end
  end
end

Test::Unit::UI::Console::TestRunner.run( XRayTest::HTML::RuleTest ) if __FILE__ == $0

