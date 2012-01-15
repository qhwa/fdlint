# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckUniqueImportTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal_script
          tag = XRay::HTML::Element.new('script', {:src=>'http://style.china.alibaba.com/lib/fdev-v4/core/fdev-min.js'})
          assert_equal [], @rule.check_html_tag(tag)
        end

        def test_check_repeated_script
          tag = XRay::HTML::Element.new('script', {:src=>'http://style.china.alibaba.com/lib/fdev-v4/core/fdev-min.js'})
          assert_equal [], @rule.check_html_tag(tag)
          (1..10).each do 
            assert_equal [["避免重复引用同一或相同功能文件", :error]], @rule.check_html_tag(tag)
          end
        end

        def test_check_with_inline_script
          tag = XRay::HTML::Element.new('script')
          assert_equal [], @rule.check_html_tag(tag)
          (1..10).each do 
            assert_equal [], @rule.check_html_tag(tag)
          end
        end

        def test_check_normal_style
          tag = XRay::HTML::Element.new('link', {:rel => 'stylesheet', :href=>'http://style.china.alibaba.com/css/lib/fdev-v4/core/fdev-min.css'}, [], :self)
          assert_equal [], @rule.check_html_tag(tag)
        end

        def test_check_repeated_style
          tag = XRay::HTML::Element.new('link', {:rel => 'stylesheet', :href=>'http://style.china.alibaba.com/css/lib/fdev-v4/core/fdev-min.css'}, [], :self)
          assert_equal [], @rule.check_html_tag(tag)
          (1..10).each do 
            assert_equal [["避免重复引用同一或相同功能文件", :error]], @rule.check_html_tag(tag)
          end
        end

      end

    end
  end
end


