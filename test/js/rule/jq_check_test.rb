require_relative 'base_test'

require 'js/rule/jq_check'

module XRayTest
  module JS
    module Rule
      
      class JqCheckTest < BaseTest
        def test_visit_expr_member
          js = 'jQuery.noConflict'
          ret = visit js, :visit_expr_member
          assert_equal 2, ret.length
        end
       
        def test_check_direct_jquery_call
          js = "jQuery.namespace"
          ret = visit js, :check_direct_jquery_call
          assert_equal nil, ret
          
          jses = [
            'jQuery.bind',
            'jQuery[method]',
            'jQuery(function($) {})',
            'jQuery.extend'
          ]

          jses.each do |js|
            message, level = visit js, :check_direct_jquery_call
            assert_equal :error, level
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
            message, level = visit js, :check_forbit_method_call
            assert_equal :error, level
          end
        end

        def test_check_data_call_param
          jses = %w(
            $.data("doc-config")
            jQuery.data('doc-config')
          )
          jses.each do |js|
            message, level = visit js, :check_data_call_param
            assert_equal :error, level
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
            message, level = visit js, :check_ctor_selector
            assert_equal :warn, level
          end

          js = '$()'
          ret = visit js, :check_ctor_selector
          assert_equal nil, ret
        end

        private

        def visit(js, action)
          expr = parse js, 'expr_member'
          rule = XRay::JS::Rule::JqCheck.new
          rule.send action, expr
        end

      end

    end
  end
end
