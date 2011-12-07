# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckBlockLevelElementTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal
          tag = Element.new('div', nil, [
            Element.new('span', nil, [
              TextElement.new('good day, commander!')
            ])
          ])
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_block_in_inline
          tag = Element.new('span', nil, [
            Element.new('div', nil, [
              TextElement.new('good day, commander!')
            ])
          ])
          assert_equal [["行内标签不得包含块级标签，a标签例外", :error]], @rule.check_tag(tag)
        end

        def test_check_inline_inline_block
          tag = Element.new('span', nil, [
            Element.new('span', nil, [
              Element.new('div', nil, [
                TextElement.new('good day, commander!')
              ])
            ])
          ])
          assert_equal [], @rule.check_tag(tag)
        end

      end

    end
  end
end

