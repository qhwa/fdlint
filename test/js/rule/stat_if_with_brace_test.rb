require_relative 'base_test'

require 'js/rule/stat_if_with_brace'

module XRayTest
  module JS
    module Rule
      
      class StatIfWithBraceTest < BaseTest
        
        def test_ok
          js = '
            if (i == 0) {
              i++; 
            } else {
              i--
            }
          '
          ret = visit js
          assert_equal nil, ret
        end

        def test_fail_1
          js = '
            if (i > 0)
              i--
            hello();
          '
          message, level = visit js
          assert_equal :error, level
        end

        def test_fail_2
          js = '
            if (hello()) {
              i--;    
            } else i++;

          '
          message, level = visit js
          assert_equal :error, level
        end

        def test_fail_3
          js = 'if (i) i--; else i++;'

          message, level = visit js
          assert_equal :error, level
        end

        private

        def visit(js)
          stat = parse js, 'stat_if'
          rule = XRay::JS::Rule::StatIfWithBrace.new
          rule.visit_stat_if stat
        end

      end

    end
  end
end
