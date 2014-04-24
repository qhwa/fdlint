# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class NestTryCatchTest < BaseTest

        check_rule [:warn, 'try catch一般不允许嵌套，若嵌套，需要充分的理由'] do
          should_with_result do
          [
            'try {
                if (a > 0) {
                }   
              } finally {
                try {
                    
                } catch (e) {
                    
                }    
              }
            ',

            'try {
              if (a > 0) {
                try {
                    
                } catch (e) {
                    
                }    
              }   
            } finally {
                
            }'
          ]
          end

          should_without_result do
            '
              try {
                    
              } catch (e) {
                  
              }
            '
          end
        end

      end

    end
  end
end
