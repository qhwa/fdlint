module XRay
  module JS
    module Expr 

      module Simple 
        
        def parse_expression
          # function
          if check /function/
            parse_function_declaration
          
          # primary
          elsif check_expr_primary
            parse_expr_primary

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
