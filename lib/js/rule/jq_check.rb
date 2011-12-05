# encoding: utf-8

require_relative '../../rule_helper'

module XRay
  module JS
    module Rule
     
      class JqCheck

        include RuleHelper, Helper

        JQ_IDS = %w(jQuery $ jQ jq)
        
        def visit_expr_member(expr)
          dispatch [
            :check_direct_jquery_call,
            :check_forbit_method_call,
            :check_data_call_param
          ], expr
        end


        def check_direct_jquery_call(expr)
          expr = find_expr_member(expr) do |expr| 
            ['.', '(', '['].include?(expr.type) && expr.left.text == 'jQuery'
          end

          unless expr
            return
          end

          unless expr.type == '.' && expr.right.text == 'namespace'
            ['禁止直接使用jQuery变量，使用全局闭包写法"(function($, NS){....})(jQuery,Namespace);"，jQuery.namespace例外', :error]
          end
        end

        def check_forbit_method_call(expr)
          methods = %w(sub noConflict)
          expr = find_expr_member(expr) do |expr|
            expr.type == '.' && JQ_IDS.include?(expr.left.text) && 
              methods.include?(expr.right.text) 
          end

          if expr
            ['禁止使用jQuery.sub()和jQuery.noConflict方法', :error]
          end
        end

        def check_data_call_param(expr)
          
          expr = find_expr_member(expr) do |expr| 
            if expr.type == '('
              name = expr.left
              if name.is_a?(Expression) && name.type == '.' && 
                  name.right.text == 'data'
                param = expr.right[0]
                param && param.text =~ /[-_]/
              end
            end  
          end
          
          if expr
            ['使用".data()"读写自定义属性时需要转化成驼峰形式', :error] 
          end
        end
         
      end
    
    end
  end
end
