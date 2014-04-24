# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class NoEvalTest < BaseTest

        should_with_result [:error, '不允许使用eval'] do
          ['eval("a = 1 + 2 + 3")',  'window.eval("1 + 2 + 3")']
        end

      end

    end
  end
end
