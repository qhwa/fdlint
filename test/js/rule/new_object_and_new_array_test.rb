# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class NewObjectAndNewArrayTest < BaseTest

        def test_default
          js = '
            new Object();
          '
          ret = visit js
          assert_equal [['使用{}代替new Object()', :error]], ret

          js = '
            new Array();
          '
          ret = visit js
          assert_equal [['使用[]代替new Array()', :error]], ret
        end
        
        private

        def visit(js)
          expr = parse js, 'expr_new'
          rule = XRay::JS::Rule::ChecklistRule.new
          rule.visit_expr_new expr
        end

      end

    end
  end
end
