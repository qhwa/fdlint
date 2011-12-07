# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckTagClosedTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal_tag
          tag = XRay::HTML::Element.new('div', {:class=>'footer'})
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_normal_tag_not_closed
          tag = XRay::HTML::Element.new('div', {:class=>'footer'})
          tag.close_type = :none
          assert_equal [["标签必须正确闭合", :error]], @rule.check_tag(tag)
        end

        def test_check_normal_tag_self_closed
          tag = XRay::HTML::Element.new('div', {:class=>'footer'})
          tag.close_type = :self
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_self_close_tag_right
          tag = XRay::HTML::Element.new('img', {:class=>'footer', :alt=>'image'})
          tag.close_type = :self
          assert_equal [], @rule.check_tag(tag)
        end
      
        def test_check_self_close_tag_close_after
          tag = XRay::HTML::Element.new('img', {:class=>'footer', :alt=>'image'})
          assert_equal [["标签必须正确闭合", :error]], @rule.check_tag(tag)
        end
      
        def test_check_text
          tag = XRay::HTML::TextElement.new('hello world')
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_comment
          tag = XRay::HTML::CommentElement.new('hello world')
          assert_equal [], @rule.check_tag(tag)
        end
      
      end

    end
  end
end

