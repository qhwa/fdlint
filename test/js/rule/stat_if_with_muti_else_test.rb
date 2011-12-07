require_relative 'base_test'

require 'js/rule/stat_if_with_muti_else'

module XRayTest
  module JS
    module Rule
      
      class StatIfWithMutiElseTest < BaseTest
        
        def test_ok
          js = '
            if (a > 0) {
                
            } else if (a > 10) {
                
            } else {    

            }
          '
          ret = visit js
          assert_equal nil, ret
        end

        def test_fail_1
          js = '
            if (a > 1) {
            } else if (a > 20) {
            } else if (a > 30) {
            } else {
            }
          '
          message, level = visit js
          assert_equal :error, level
        end

        def test_fail_2
          js = '
            if (a > 2) {
            } else if (a > 40) {
            } else if (a > 50) {
            } else if (a > 60) {
            }
          '
          message, level = visit js
          assert_equal :error, level
        end



        private

        def visit(js)
          stat = parse js, 'stat_if'
          rule = XRay::JS::Rule::StatIfWithMutiElse.new
          rule.visit_stat_if stat
        end

      end

    end
  end
end
