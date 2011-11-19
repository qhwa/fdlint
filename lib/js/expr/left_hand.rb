module XRay
  module JS
    module Expr
      
      module LeftHand
        
        def parse_expr_lefthand
          check /new\b/ ? parse_expr_new : parse_expr_call
        end 

        def parse_expr_new
          log 'parse expr new'

          pos = skip /new/
          expr = check(/new\b/) ? parse_expr_new : parse_expr_member

          CompositeExpression.new 'new', expr, nil, pos
        end

        def parse_expr_member
          expr = if check /function\b/
            parse_function_declaration
          elsif check /new\b/
            pos = skip /new/
            sub_expr = parse_expr_member
            
          else
            parse_expr_primary
          end 

          while check /[\[.]/
            right = if check /[.]/
              type = '.'
              skip /[.]/
              parse_expr_identifier 
            elsif check /\[/
              type = '[]'
              skip /\[/
              parse_expression
              skip /]/
            end
            
            expr = CompositeExpression.new type, expr, right
          end

          expr
        end



      end

    end
  end
end
