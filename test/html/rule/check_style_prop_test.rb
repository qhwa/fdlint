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
          prop = XRay::HTML::Property.new('href', '#nogo')
          assert_equal [], @rule.check_html_property(prop)
        end

        def test_check_tag_with_style_prop
          prop = XRay::HTML::Property.new('style', 'nogo')
          assert_equal [["不能定义内嵌样式style", :error]], @rule.check_html_property(prop)
        end

      end

    end
  end
end
