# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
      
      class JqCheckTest < BaseTest

        
        should_with_result [:error, '禁止使用jQuery.sub()和jQuery.noConflict方法'] do
          %w{
            jQ.noConflict
            $.sub
            $.noConflict
            jQuery.sub
            jQuery.noConflict
          }
        end

        check_rule [:error, '禁止直接使用jQuery变量，使用全局闭包写法，jQuery.namespace例外'] do
          should_with_result do
            %w{
              jQuery.bind
              jQuery[method]
              jQuery(function($)\ {})
              jQuery.extend
            }
          end

          next

          should_without_result do
            "jQuery.namespace"
          end
        end

        should_with_result [:error, '使用".data()"读写自定义属性时需要转化成驼峰形式'] do
          %w{
            $.data("doc-config")
            jQuery.data('doc-config')
          }
        end

        should_with_result [:warn, '使用选择器时，能确定tagName的，必须加上tagName'] do
          [
            "$('.myclass', div)",
            "$('.myclass')",
            "$('[name=123]')",
            "$(':first')"
          ]
        end

      end

    end
  end
end
