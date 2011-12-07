# encoding: utf-8

module XRay
  module JS
    module Rule
     
      class NewObjectAndNewArray
        
        def visit_expr_new(expr)
          expr = expr.left 
          expr = expr.left if expr.type == '('

          if expr.type == 'id'
            if expr.text == 'Object'
              ['使用{}代替new Object()', :error]
            elsif expr.text == 'Array'
              ['使用[]代替new Array()', :error]
            end 
          end
        end
         
      end
    
    end
  end
end
