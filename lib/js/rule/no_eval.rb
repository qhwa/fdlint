# encoding: utf-8

require_relative 'helper'

module XRay
  module JS
    module Rule
     
      class NoEval

        include Helper
        
        def visit_expr_member(expr)
          expr = find_expr_member(expr) { |expr| expr.type == '(' }
          checks = %w(
            (.,window,eval)
            eval
          )
          if expr && checks.include?(expr.left.text)
            ['不允许使用eval', :error] 
          end
        end
         
      end
    
    end
  end
end
