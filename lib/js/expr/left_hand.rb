module XRay
  module JS
    module Expr
      
      module LeftHand
        
        def parse_expr_lefthand
          log 'parse expr lefthand'
          expr = check(/new\b/) ? parse_expr_new : parse_expr_member
          expr.left_hand = true
          expr 
        end 

        def parse_expr_new
          log 'parse expr new'

          pos = skip /new/
          expr = check(/new\b/) ? parse_expr_new : parse_expr_member
          args = check(/\(/) ? parse_arguments_list : nil

          create_element Expression, 'new', expr, args, pos
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
            elsif check /\(/
              ['(', parse_arguments_list]
            end
          end
        end

        protected

        def parse_expr_member_left
          if check /function\b/
            parse_function_declaration(true)
          else
            parse_expr_primary
          end 
        end


        def parse_arguments_list
          log 'parse arguments list'
          skip /\(/
          params = batch(:parse_expr_assignment, /\)/, /,/)
          skip /\)/
          Elements.new params
        end

      end
    end
  end
end
