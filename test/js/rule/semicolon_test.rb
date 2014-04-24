# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class SemicolonTest < BaseTest

        check_rule [:error, '所有语句结束带上分号'] do
          
          should_with_result do 
            [
              %Q{var a = 1, b = 2
              a++;},

              %Q{a = i + 1 + 2 + 3 * 9
              i++}
            ]
          end

          should_without_result do
            [
              %Q{ i = i++; },
              ';' 
            ]
          end
        end

      end

    end
  end
end
