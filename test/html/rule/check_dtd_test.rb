# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckDTDTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_html5_dtd
          tag = XRay::HTML::DTDElement.new('html')
          assert_equal [], @rule.check_html_dtd(tag)
        end

        def test_check_xhtml_dtd
          src = %q(html 
             PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
             "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd")
          tag = XRay::HTML::DTDElement.new(src)
          assert_equal [['新页面统一使用HTML 5 DTD', :warn]], @rule.check_html_dtd(tag)
        end

        def test_check_doctype_upcase
          tag = XRay::HTML::DTDElement.new('html', 'doctype')
          assert_equal [['必须使用大写的"DOCTYPE"', :warn]], @rule.check_html_dtd(tag)
        end

        def test_check_dtd_available
          doc = XRay::HTML::Parser.new('<html><body></body></html>')
          assert @rule.check_html_doc(doc).include?(['必须存在文档类型声明', :error])
        end

      end

    end
  end
end



