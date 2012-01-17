# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class JqCheckTest < BaseTest
        def test_visit_expr_member
          js = 'jQuery.noConflict'
          ret = visit js
          assert_equal 2, ret.length
        end
       
        def test_check_direct_jquery_call
          js = "jQuery.namespace"
          ret = visit js
          assert_equal [], ret
          
          jses = [
            'jQuery.bind',
            'jQuery[method]',
            'jQuery(function($) {})',
            'jQuery.extend'
          ]

          jses.each do |js|
            r = visit js
            assert r.include? ['禁止直接使用jQuery变量，使用全局闭包写法"(function($, NS){....})(jQuery,Namespace);"，jQuery.namespace例外', :error]
          end
        end 

        def test_check_forbit_method_call
          jses = %w(
            $.sub
            $.noConflict
            jQuery.sub
            jQuery.noConflict
          )

          jses.each do |js|
            r = visit js
            assert r.include?( ['禁止使用jQuery.sub()和jQuery.noConflict方法', :error] )
          end
        end

        def test_check_data_call_param
          jses = %w(
            $.data("doc-config")
            jQuery.data('doc-config')
          )
          jses.each do |js|
            r = visit js
            assert r.include? ['使用".data()"读写自定义属性时需要转化成驼峰形式', :error]
          end
        end

        def test_check_ctor_selector
          jses = [
            "$('.myclass', div)",
            "$('.myclass')",
            "$('[name=123]')",
            "$(':first')"
          ]
          
          jses.each do |js|
            r = visit js
            assert r.include? ['使用选择器时，能确定tagName的，必须加上tagName', :warn]
          end

          js = '$()'
          ret = visit js
          assert_equal [], ret
        end

        private

        def visit(js)
          expr = parse js, 'expr_member'
          rule = XRay::JS::Rule::Checklist.new
          rule.send :visit_expr_member, expr
        end

      end

    end
  end
end
