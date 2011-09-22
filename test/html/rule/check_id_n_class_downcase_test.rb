# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckIDAndClassPropCaseTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_downcase_id
          prop = XRay::HTML::Property.new('id', 'uploader')
          assert_equal [], @rule.check_prop(prop)
        end

        def test_check_downcase_class
          prop = XRay::HTML::Property.new('class', 'uploader info')
          assert_equal [], @rule.check_prop(prop)
        end

        def test_check_upcase_id
          prop = XRay::HTML::Property.new('id', 'Nogo')
          assert_equal [["id名称全部小写，单词分隔使用中横线", :warn]], @rule.check_prop(prop)
        end

        def test_check_upcase_class
          prop = XRay::HTML::Property.new('class', 'Nogo')
          assert_equal [["class名称全部小写，单词分隔使用中横线", :warn]], @rule.check_prop(prop)
        end

      end

    end
  end
end
