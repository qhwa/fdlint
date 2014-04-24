# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class StatIfWithMutiElseTest < BaseTest

        check_rule [:error, '3个条件及以上的条件语句用switch代替if else'] do
          
          should_with_result do 
            [
              %Q{
                if (a > 1) {
                } else if (a > 20) {
                } else if (a > 30) {
                } else {
                }
              },

              %Q{
                if (a > 2) {
                } else if (a > 40) {
                } else if (a > 50) {
                } else if (a > 60) {
                }
              }
            ]
          end

          should_without_result do
            [
              %Q{
                if (a > 0) {
                    
                } else if (a > 10) {
                    
                } else {    

                }
              },
            ].last
          end
        end

      end

    end
  end
end
