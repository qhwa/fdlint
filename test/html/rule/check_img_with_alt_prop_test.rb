# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckImgWithAltPropTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_img_with_alt
          tag = XRay::HTML::Element.new('img', {:src=>'http://pnq.cc/icon.png', :alt=>'图片'}, [], :self)
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_img_without_alt
          tag = XRay::HTML::Element.new('img', {:src=>'http://pnq.cc/icon.png'}, [], :self)
          assert_equal [["img标签必须加上alt属性", :warn]], @rule.check_tag(tag)
        end

      end

    end
  end
end



