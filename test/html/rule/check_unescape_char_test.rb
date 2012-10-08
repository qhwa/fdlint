# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckUnescapedCharTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal_text_tag
          tag = XRay::HTML::TextElement.new('hello')
          assert_equal [], @rule.check_html_text(tag)
        end
      
        def test_check_text_el_with_rt
          tag = XRay::HTML::TextElement.new('>>>')
          assert_equal [["特殊HTML符号(>和<)必须转义", :error]], @rule.check_html_text(tag)
        end

        def test_check_text_el_with_lt
          tag = XRay::HTML::TextElement.new('<<<<')
          assert_equal [["特殊HTML符号(>和<)必须转义", :error]], @rule.check_html_text(tag)
        end

      end

    end
  end
end
