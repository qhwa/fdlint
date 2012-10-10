# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckCSSInHeadTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_alone_css_tag
          tag = css_link('test.css')
          assert_equal [], @rule.check_html_tag(tag)
        end

        def test_check_css_tag_in_head
          tag = css_link('test.css')
          head = XRay::HTML::Element.new('head', nil, [tag])
          assert_equal [], @rule.check_html_tag(tag)
        end

        def test_check_css_tag_in_body
          tag = css_link('test.css')
          body = XRay::HTML::Element.new('body', nil, [tag])
          assert_equal [["外链CSS置于head里(例外：应用里的footer样式)", :warn]], @rule.check_html_tag(tag)
        end

        def test_from_fixture
          results = XRay::Runner.new.check_html( fixture "html/css_out_of_head.html" )
          found = results.find_all do |res|
            res.message == "外链CSS置于head里(例外：应用里的footer样式)"
          end
          assert_equal 1, found.size
        end

        protected
        def css_link(src)
          XRay::HTML::Element.new('link', {:rel => 'stylesheet', :href=>src}, [], :self)
        end

      end

    end
  end
end



