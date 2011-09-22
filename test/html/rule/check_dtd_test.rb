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
          assert_equal [], @rule.check_dtd(tag)
        end

        def test_check_xhtml_dtd
          src = %q(<!DOCTYPE html 
             PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
             "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">)
          tag = XRay::HTML::DTDElement.new(src)
          assert_equal [['新页面统一使用HTML 5 DTD', :info]], @rule.check_dtd(tag)
        end

      end

    end
  end
end



