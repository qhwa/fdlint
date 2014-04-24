# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class StatIfWithBraceTest < BaseTest

        check_rule [:error, '所有条件区域必须用花括号括起来'] do
          
          should_with_result do 
            [
              %Q{
                if (hello()) {
                  i--;    
                } else i++;
              },
              %Q{
                if (i > 0)
                  i--
                hello();
              }
            ]
          end

          should_without_result do
            [
              %Q{
                if (i == 0) {
                  i++; 
                } else {
                  i--
                }
              },
              %Q{ 'if (i) i--; else i++;'}
            ]
          end
        end

      end

    end
  end
end
