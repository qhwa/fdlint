# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckPropSeperatorTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_double_quote
          prop = XRay::HTML::Property.new('id', 'info', "\"")
          assert_equal [], @rule.check_html_property(prop)
        end

        def test_check_single_quote
          prop = XRay::HTML::Property.new('id', 'info', "\'")
          assert_equal [["属性值必须使用双引号", :error]], @rule.check_html_property(prop)
        end

      end

    end
  end
end
