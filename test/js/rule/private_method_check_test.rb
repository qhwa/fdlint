# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class PrivateMethodCheckTest < BaseTest

        check_rule [:error, '禁止调用对象的私有方法'] do
          
          should_with_result do 
            %w[a._check('good')
               a._check.call(a,\ 'good')
               a.__check('good')]
          end

          should_without_result do
            %w[a.check("good")
            this.__check('good')
            self._check('good')]
          end
        end

      end

    end
  end
end
