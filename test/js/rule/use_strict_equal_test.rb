require_relative 'base_test'

require 'js/rule/use_strict_equal'

module XRayTest
  module JS
    module Rule
      
      class UseStrictEqualTest < BaseTest

        def test_ok
          js = 'i === 1 + 1 / 2'
          ret = visit js
          assert_equal nil, ret 

          js = 'i !== hello()'
          ret = visit js
          assert_equal nil, ret
        end

        def test_fail
          js = 'i == 1 + 1 / 2'
          message, level = visit js
          assert_equal :warn, level

          js = 'i != hello()'
          message, level = visit js
          assert_equal :warn, level
        end
        
        private

        def visit(js)
          expr = parse js, 'expr_equal'
          rule = XRay::JS::Rule::UseStrictEqual.new
          rule.visit_expr_equal expr
        end

      end

    end
  end
end
