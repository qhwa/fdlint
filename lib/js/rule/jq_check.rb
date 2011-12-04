# encoding: utf-8

require_relative '../../rule_helper'

module XRay
  module JS
    module Rule
     
      class JqCheck

        include RuleHelper

        JQ_IDS = %w(jQuery $ jQ jq)
        
        def visit_expr_member(expr)
          dispatch [
            :check_direct_jquery_call,
            :check_forbit_method_call,
            :check_data_call_param
          ], expr
        end


        def check_direct_jquery_call(expr)
          unless expr.left.type == 'id' && expr.left.text == 'jQuery'
            return
          end

          if expr.type == '.' && expr.right.text != 'namespace' || expr.type != '.'
              
            ['禁止直接使用jQuery变量，使用全局闭包写法"(function($, NS){....})(jQuery,Namespace);"，jQuery.namespace例外', :error]
          end
        end

        def check_forbit_method_call(expr)
          methods = %w(sub noConflict)
          if expr.type == '.' && 
              expr.left.type == 'id' && JQ_IDS.include?(expr.left.text) &&
              methods.include?(expr.right.text)
            ['禁止使用jQuery.sub()和jQuery.noConflict方法', :error]
          end
        end

        def check_data_call_param(expr)
          unless expr.type == '('
            return
          end

          name = expr.left
          if name.type == '.' && 
              name.left.type == 'id' && JQ_IDS.include?(name.left.text) &&
              name.right.text == 'data' 
            param = expr.right[0].text
            unless param && /^[a-z][a-zA-Z0-9]*$/ =~ param
              ['使用".data()"读写自定义属性时需要转化成驼峰形式', :error] 
            end
          end
        end
         
      end
    
    end
  end
end
