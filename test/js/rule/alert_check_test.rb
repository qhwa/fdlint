# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class AlertCheckTest < BaseTest

        def test_visit_alert
          js = 'alert'
          ret = visit js
          assert_equal 1, ret.length
        end
       
        def test_vist_window_alert
          js = "window.alert"
          ret = visit js
          assert_equal [], ret
        end 

        private

        def visit(js)
          expr = parse js, 'expr_member'
          rule = XRay::JS::Rule::ChecklistRule.new
          rule.send :visit_expr_member, expr
        end

      end

    end
  end
end

