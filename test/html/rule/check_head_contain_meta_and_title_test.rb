# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckHeadTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
          @expect = ["head必须包含字符集meta和title", :error]
        end

        def test_check_right_tag
          tag = XRay::HTML::Element.new('head',nil, [
            Element.new('meta', {:charset => 'utf-8'}),
            Element.new('title', nil, [TextElement.new('hello world!')]),
            Element.new('meta', {:name => 'description'}),
            Element.new('meta', {:name => 'keywords'})
          ])
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_simple_head
          tag = XRay::HTML::Element.new('head')
          assert @rule.check_tag(tag).include?(@expect)
        end

        def test_check_head_without_meta
          tag = XRay::HTML::Element.new('head',nil, [
            Element.new('title', nil, [TextElement.new('hello world!')])
          ])
          assert @rule.check_tag(tag).include?(@expect)
        end

        def test_check_head_without_title
          tag = XRay::HTML::Element.new('head',nil, [
            Element.new('meta', {:charset => 'utf-8'})
          ])
          assert @rule.check_tag(tag).include?(@expect)
        end

      end

    end
  end
end
