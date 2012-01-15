# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class StatIfWithMutiElseTest < BaseTest

        def setup
          @msg = '3个条件及以上的条件语句用switch代替if else'
        end
        
        def test_ok
          js = '
            if (a > 0) {
                
            } else if (a > 10) {
                
            } else {    

            }
          '
          ret = visit js
          assert_equal [], ret
        end

        def test_fail_1
          js = '
            if (a > 1) {
            } else if (a > 20) {
            } else if (a > 30) {
            } else {
            }
          '
          ret = visit js
          assert_equal [[@msg, :error]], ret
        end

        def test_fail_2
          js = '
            if (a > 2) {
            } else if (a > 40) {
            } else if (a > 50) {
            } else if (a > 60) {
            }
          '
          ret = visit js
          assert_equal [[@msg, :error]], ret
        end



        private

        def visit(js)
          stat = parse js, 'stat_if'
          rule = XRay::JS::Rule::Checklist.new
          rule.visit_stat_if stat
        end

      end

    end
  end
end
