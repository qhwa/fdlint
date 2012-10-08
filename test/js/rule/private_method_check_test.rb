# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class PrivateMethodCheckTest < BaseTest

        def test_normal
          js = 'a.check("good")'
          ret = visit js
          assert_equal [], ret
        end
       
        def test_protected_called
          js = "a._check('good')"
          ret = visit js
          assert_equal 1, ret.length
        end 

        def test_protected_called_via_apply
          js = "a._check.call(a, 'good')"
          ret = visit js
          assert_equal 1, ret.length
        end

        def test_private_called
          js = "a.__check('good')"
          ret = visit js
          assert_equal 1, ret.length
        end

        def test_good_case
          js = "this.__check('good')"
          ret = visit js
          assert_equal [], ret

          js = "self._check('good')"
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
