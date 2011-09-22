# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckPropHaveValueTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_double_quote
          prop = XRay::HTML::Property.new('checked', 'true')
          assert_equal [], @rule.check_prop(prop)
        end

        def test_check_single_quote
          prop = XRay::HTML::Property.new('checked', nil)
          assert_equal [["不能仅有属性名", :warn]], @rule.check_prop(prop)
        end

      end

    end
  end
end
