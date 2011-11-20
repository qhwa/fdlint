module XRay
  module JS
    module Expr
      
      module Postfix

        def parse_expr_postfix
          log 'parse expr postfix'
          expr = parse_expr_lefthand
          if check(/[ \t]*(?:\+\+|--)/, false)
            op = scan /\+\+|--/
            expr = Expression.new op.text, expr
          end
          expr
        end
        
      end

    end
  end
end
