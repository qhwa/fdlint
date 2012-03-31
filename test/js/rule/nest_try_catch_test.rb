# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class NestTryCatchTest < BaseTest

        def test_ok
          js = '
            try {
                  
            } catch (e) {
                
            }
          '
          ret = visit js
          assert_equal [], ret
        end

        def test_fail
          js = '
            try {
              if (a > 0) {
                try {
                    
                } catch (e) {
                    
                }    
              }   
            } finally {
                
            }
          '
          ret = visit js
          assert_equal [['try catch一般不允许嵌套，若嵌套，需要充分的理由', :warn]], ret
        end
        
        def test_nest_in_finnally_part
          js = '
            try {
              if (a > 0) {
              }   
            } finally {
              try {
                  
              } catch (e) {
                  
              }    
            }
          '
          ret = visit js
          assert_equal [['try catch一般不允许嵌套，若嵌套，需要充分的理由', :warn]], ret
        end
        
        private

        def visit(js)
          stat = parse js, 'stat_try'
          rule = XRay::JS::Rule::ChecklistRule.new
          rule.visit_stat_try stat
        end

      end

    end
  end
end
