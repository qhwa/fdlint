# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class UseStrictEqualTest < BaseTest

        check_rule [:warn, '避免使用==和!=操作符'] do
          
          should_with_result do 
            [
              'i == 1 + 1 / 2',
              'i != hello()'
            ]
          end

          should_without_result do
            [
              'i === 1 + 1 / 2',
              'i !== hello()'
            ]
          end
        end

      end

    end
  end
end
