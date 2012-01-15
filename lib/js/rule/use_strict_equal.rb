# encoding: utf-8
require_relative '../../rule'

module XRay
  module JS
    module Rule
     
      class UseStrictEqual 
        
        include XRay::Rule

        def visit_expr_equal(expr)
          check_js_expr_equal expr
        end
         
      end

    end
  end
end
