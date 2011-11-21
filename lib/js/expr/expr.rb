require_relative 'primary'
require_relative 'left_hand'
require_relative 'operate'


module XRay
  module JS
    module Expr 

      module Expr
        include Primary, LeftHand, Operate
        
        def parse_expression
          log 'parse expression'
          parse_expr_with_operate :parse_expr_assignment, /,/ 
        end

        def parse_expr_assignment
          log 'parse expr assignment'

          expr = parse_expr_condition

          r = /=|\*=|\/=|%=|\+=|-=|<<=|>>=|>>>=|&=|\^=|\|=/
          if expr.left_hand? && check(r)
            op = scan r
            expr = Expression.new op.text, expr, parse_expr_assignment
          end
          expr
        end

        def parse_expr_condition
          log 'parse expr condition'
          expr = parse_expr_logical_or
          if check /\?/
            skip /\?/
            left = parse_expr_assignment
            skip /:/
            right = parse_expr_assignment

            expr = ConditionExpression.new expr, left, right
          end
          expr
        end

        protected

        def parse_expr_with_operate(left, pattern = nil, &block)
          block = block || lambda {
            if check pattern
              op = scan pattern
              [op.text, self.send(left)]
            end
          }

          expr = self.send left
          while (ret = block.call) 
            expr = Expression.new ret[0], expr, ret[1]
          end 

          log "  #{expr}"
          expr
        end
         
      end

    end
  end
end
