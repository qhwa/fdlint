# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckNoCSSImportTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal
          tag = XRay::HTML::Element.new('style', nil, [
            TextElement.new('body { background-color:#fff; }')
          ])
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_style_with_import
          tag = XRay::HTML::Element.new('style', nil, [
            TextElement.new('@import style.css')
          ])
          assert_equal [["不通过@import在页面上引入CSS", :warn]], @rule.check_tag(tag)
        end

      end

    end
  end
end
