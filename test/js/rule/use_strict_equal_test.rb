# encoding: utf-8
require_relative 'base_test'

require 'js/rule/use_strict_equal'

module XRayTest
  module JS
    module Rule
      
      class UseStrictEqualTest < BaseTest

        def test_ok
          js = 'i === 1 + 1 / 2'
          ret = visit js
          assert_equal [], ret 

          js = 'i !== hello()'
          ret = visit js
          assert_equal [], ret
        end

        def test_fail
          js = 'i == 1 + 1 / 2'
          ret = visit js
          assert_equal [['避免使用==和!=操作符', :warn]], ret

          js = 'i != hello()'
          ret = visit js
          assert_equal [['避免使用==和!=操作符', :warn]], ret
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
