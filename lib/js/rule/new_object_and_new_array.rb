# encoding: utf-8
require_relative '../../rule'

module XRay
  module JS
    module Rule
     
      class NewObjectAndNewArray

        include XRay::Rule
        
        def visit_expr_new(expr)
          check_js_expr_new expr
        end
         
      end
    
    end
  end
end
