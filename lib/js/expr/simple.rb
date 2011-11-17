module XRay
  module JS
    module Expr 

      module Simple 
        
        def parse_expression
          # (expression)
          if check(/\(/)
            skip /\(/
            expr = parse_expression
            skip /\)/
            expr
         
          # function expression
          elsif check /function/
            parse_function_declaration
          
          # this
          elsif check_expr_literal 
            parse_expr_literal
          else
            parse_expr_simple
          end
        end

        def parse_expr_assignment
          log 'parse expr assignment'
          parse_expression
        end


        def parse_expr_simple
          log 'parse expr simple'

          expr = Expression.new scan (/[^;]*/)
          log "  #{expr}"
          expr
        end
         
      end

    end
  end
end
