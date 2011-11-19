module XRay
  module JS
    module Expr
      
      module LeftHand
        
        def parse_expr_lefthand
          check(/new\b/) ? parse_expr_new : parse_expr_call
        end 

        def parse_expr_new
          log 'parse expr new'

          pos = skip /new/
          expr = check(/new\b/) ? parse_expr_new : parse_expr_member

          CompositeExpression.new 'new', expr, nil, pos
        end

        def parse_expr_member
          log 'parse expr member'
          parse_expr_with_operate(:parse_expr_member_left) do
            if check /[.]/
              skip /[.]/
              ['.', parse_expr_identifier]

            elsif check /[\[]/
              skip /\[/
              expr = parse_expression
              skip /]/
              ['[', expr]
            end
          end 
        end

        protected

        def parse_expr_member_left
          if check /function\b/
            parse_function_declaration
          elsif check /new\b/
            pos = skip /new/
            expr = parse_expr_member
            skip /\(/
            params = batch(:parse_expr_assignment, /\)/, /,/)
            skip /\)/
            Expression.new 'new', expr, ElementsNode.new(params), pos
          else
            parse_expr_primary
          end 
        end

      end

    end
  end
end
