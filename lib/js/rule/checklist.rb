# encoding: utf-8
require_relative 'helper'
require_relative '../../rule'

module XRay
  module JS
    module Rule
     
      class Checklist

        include XRay::JS::Rule::Helper, XRay::Rule
        
        def visit_statement(stat)
          check_js_statement stat
        end

        def visit_stat_if(stat)
          check_js_stat_if stat
        end
         
        def visit_expr_member(expr)
          check_js_expr_member expr
        end
         
        def visit_expr_new(expr)
          check_js_expr_new expr
        end
         
        def visit_expr_equal(expr)
          check_js_expr_equal expr
        end
         
        def visit_stat_try(stat)
          check_js_stat_try stat
        end

      end
    
    end
  end
end
