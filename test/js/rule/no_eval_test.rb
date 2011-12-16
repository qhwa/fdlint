require_relative 'base_test'

require 'js/rule/no_eval'

module XRayTest
  module JS
    module Rule
      
      class NoEvalTest < BaseTest
       
        def test_no_eval
          js = 'eval("a = 1 + 2 + 3")' 
          message, level = visit js
          assert_equal :error, level

          js = 'window.eval("1 + 2 + 3")'
          message, level = visit js
          assert_equal :error, level
        end 

        private

        def visit(js)
          expr = parse js, 'expr_member'
          rule = XRay::JS::Rule::NoEval.new
          rule.visit_expr_member expr
        end

      end

    end
  end
end
