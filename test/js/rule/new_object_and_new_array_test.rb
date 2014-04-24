# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class NewObjectAndNewArrayTest < BaseTest

        should_with_result [:error, '使用{}代替new Object()'] do
          ['new Object()', 'new Object']
        end

        should_with_result [:error, '使用[]代替new Array()'] do
          ['new Array()', 'new Array']
        end

      end

    end
  end
end
