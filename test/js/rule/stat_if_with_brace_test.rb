# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class StatIfWithBraceTest < BaseTest

        def setup
          @msg = '所有条件区域必须用花括号括起来'
        end
        
        def test_ok
          js = '
            if (i == 0) {
              i++; 
            } else {
              i--
            }
          '
          ret = visit js
          assert_equal [], ret
        end

        def test_fail_1
          js = '
            if (i > 0)
              i--
            hello();
          '
          ret = visit js
          assert_equal [[@msg, :error]], ret
        end

        def test_fail_2
          js = '
            if (hello()) {
              i--;    
            } else i++;

          '
          ret = visit js
          assert_equal [[@msg, :error]], ret
        end

        def test_fail_3
          js = 'if (i) i--; else i++;'

          ret = visit js
          assert_equal [[@msg, :error]], ret
        end

        private

        def visit(js)
          stat = parse js, 'stat_if'
          rule = XRay::JS::Rule::ChecklistRule.new
          rule.visit_stat_if stat
        end

      end

    end
  end
end
