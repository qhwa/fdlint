# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckHyperlinkWithTargetTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_functional_a_with_target
          tag = XRay::HTML::Element.new('a', {:href=>'#nogo', :target=>'_self'})
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_functional_a_without_target
          tag = XRay::HTML::Element.new('a', {:href=>'#nogo'})
          assert_equal [['功能a必须加target="_self"，除非preventDefault过', :warn]], @rule.check_tag(tag)
        end

      end

    end
  end
end



