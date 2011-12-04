require_relative 'base_test'

require 'js/rule/nest_try_catch'

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
          assert_equal nil, ret
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
          message, level = visit js
          assert_equal :warn, level
        end
        
        private

        def visit(js)
          stat = parse js, 'stat_try'
          rule = XRay::JS::Rule::NestTryCatch.new
          rule.visit_stat_try stat
        end

      end

    end
  end
end
