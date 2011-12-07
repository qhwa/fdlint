# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckHyperlinkWithTitleTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_functional_a_with_title
          tag = XRay::HTML::Element.new('a', {:href=>'#nogo', :title=>'it is a hyperlink', :target=>'_self'})
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_functional_a_without_title
          tag = XRay::HTML::Element.new('a', {:href=>'#nogo', :target=>'_self'})
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_normal_a_with_title
          tag = XRay::HTML::Element.new('a', {:href=>'new-page.html', :title=>'new page'})
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_normal_a_without_title
          tag = XRay::HTML::Element.new('a', {:href=>'new-page.html'})
          assert_equal [['非功能能点的a标签必须加上title属性', :error]], @rule.check_tag(tag)
        end

      end

    end
  end
end



