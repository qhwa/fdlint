require 'fdlint/parser/js/expr/primary'
require 'fdlint/parser/js/expr/left_hand'
require 'fdlint/parser/js/expr/operate'


module Fdlint
  module Parser
    module JS
      module Expr 

        module Expr

          include ::Fdlint::Parser::JS::Expr::Primary
          include ::Fdlint::Parser::JS::Expr::LeftHand
          include ::Fdlint::Parser::JS::Expr::Operate
          
          def parse_expression
            debug { 'parse expression' }
            parse_expr_with_operate :parse_expr_assignment, /,/ 
          end

          def parse_expr_assignment
            debug { 'parse expr assignment' }

            expr = parse_expr_condition

            r = /=|\*=|\/=|%=|\+=|-=|<<=|>>=|>>>=|&=|\^=|\|=/
            if expr.left_hand? && check(r)
              op = scan r
              expr = create_element Expression, op.text, expr, parse_expr_assignment
            end
            expr
          end

          def parse_expr_condition
            debug { 'parse expr condition' }
            expr = parse_expr_logical_or
            if check /\?/
              skip /\?/
              left = parse_expr_assignment
              skip /:/
              right = parse_expr_assignment

              expr = create_element ConditionExpression, expr, left, right
            end
            expr
          end

          def parse_expr_with_operate(left, pattern = nil, &block)
            block = block || lambda {
              if check pattern
                skip_empty
                before_pos = scanner_pos
                op = scan pattern
                [op.text, self.send(left), before_pos]
              end
            }

            expr = self.send left
            while (ret = block.call) 
              expr = create_element Expression, ret[0], expr, ret[1], ret[2]
            end 
            expr
          end
           
        end

      end
    end
  end
end
