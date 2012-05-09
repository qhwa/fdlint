# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckTagDowncaseTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal_prop_name
          prop = XRay::HTML::Property.new('href', '#nogo')
          assert_equal [], @rule.check_html_property(prop)
        end

        def test_check_normal_tag_name
          tag = XRay::HTML::Element.new('div', {:class=>'footer'})
          assert_equal [], @rule.check_html_tag(tag)
        end
      
        def test_check_tag_with_upcase_name
          tag = XRay::HTML::Element.new('DIV', {:class=>'footer'})
          assert_equal [["标签名必须小写", :error]], @rule.check_html_tag(tag)
        end

        def test_check_tag_with_upcase_ending
          tag = XRay::HTML::Element.new('div', nil, [], :after, '</DIV>')
          assert_equal [["标签名必须小写", :error]], @rule.check_html_tag(tag)
        end

        def test_check_tag_with_simple_upcase_prop_name
          prop = XRay::HTML::Property.new('Href', 'nogo')
          assert_equal [["属性名必须小写，连字符用中横线", :error]], @rule.check_html_property(prop)
        end

        def test_check_tag_with_style_prop
          prop = XRay::HTML::Property.new('Style', 'nogo')
          assert_equal [["不能定义内嵌样式style", :error], ["属性名必须小写，连字符用中横线", :error]], @rule.check_html_property(prop)
        end

      end

    end
  end
end

