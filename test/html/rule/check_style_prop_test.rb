# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckStylePropTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal
          assert_equal [], @rule.check_prop_name(XRay::Node.new('href'))
        end

        def test_check_tag_with_style_prop
          assert_equal [["不能定义内嵌样式style", :warn]], @rule.check_prop_name(XRay::Node.new('style'))
        end

      end

    end
  end
end
