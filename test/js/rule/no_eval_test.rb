# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class NoEvalTest < BaseTest
       
        def test_no_eval
          js = 'eval("a = 1 + 2 + 3")' 
          ret = visit js
          assert_equal [['不允许使用eval', :error]], ret

          js = 'window.eval("1 + 2 + 3")'
          ret = visit js
          assert_equal [['不允许使用eval', :error]], ret
        end 

        private

        def visit(js)
          expr = parse js, 'expr_member'
          rule = XRay::JS::Rule::ChecklistRule.new
          rule.visit_expr_member expr
        end

      end

    end
  end
end
