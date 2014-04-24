# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckDTDTest < Test::Unit::TestCase

        include FdlintTest::HTML

        def setup
        end

        def test_check_html5_dtd
          parse '<!DOCTYPE html>' do |results|
            assert results.blank?
          end
        end

        def test_check_xhtml_dtd
          src = %q(html 
             PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
             "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd")
          parse DTDElement.new(src).outer_html do |results|
            assert_has_result results, [:warn, '推荐使用HTML 5 DTD']
          end
        end

        def test_check_doctype_upcase
          parse '<!doctype html>' do |results|
            assert_has_result results, [:warn, '必须使用大写的"DOCTYPE"']
          end
        end

        def test_check_dtd_available
          parse '<html><body></body></html>' do |results|
            assert_has_result results, [:error, '必须存在文档类型声明']
          end
        end

      end

    end
  end
end



