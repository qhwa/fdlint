# encoding: utf-8

require_relative 'helper'
require_relative '../../rule'

module XRay
  module JS
    module Rule
     
      class NoEval

        include Helper, XRay::Rule
        
        def visit_expr_member(expr)
          check_js_expr_member expr
        end
         
      end
    
    end
  end
end
