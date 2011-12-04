# encoding: utf-8

module XRay
  module JS
    module Rule
     
      class NoEval
        
        def visit_expr_member(expr)
          if expr.type == '(' && 
                expr.left.type == 'id' && expr.left.text == 'eval'
            ['不允许使用eval', :error] 
          end
        end
         
      end
    
    end
  end
end
