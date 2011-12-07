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
              ['使用{}代替new Object()', :warn]
            elsif expr.text == 'Array'
              ['使用[]代替new Array()', :warn]
            end 
          end
        end
         
      end
    
    end
  end
end
