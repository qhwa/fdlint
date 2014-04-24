# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class AlertCheckTest < BaseTest

        check_rule [:warn, '必须去掉临时调试代码。如果一定要使用alert功能，请使用 window.alert'] do

          should_with_result do
            'alert'
          end

        end

      end

    end
  end
end

