module XRay
  module JS
    module Expr
      
      module Operate

        def parse_expr_postfix
          log 'parse expr postfix'
          expr = parse_expr_lefthand
          if check(/[ \t]*(?:\+\+|--)/, false)
            op = scan /\+\+|--/
            expr = Expression.new op.text, expr
          end
          expr
        end

        def parse_expr_unary
          log 'parse expr unary'
          r = /delete|void|typeof|\+\+|--|\+|-|~|!/
          if check r
            op = scan r
            Expression.new op.text, nil, parse_expr_unary
          else
            parse_expr_postfix
          end
        end

        def parse_expr_mul
          log 'parse expr mul'
          parse_expr_with_operate :parse_expr_unary, /\*|\/|%/
        end

        def parse_expr_add
          log 'parse expr add'
          parse_expr_with_operate :parse_expr_mul, /\+|-/
        end

        def parse_expr_shift
          log 'parse expr shift'
          parse_expr_with_operate :parse_expr_add, /<<|>>>|>>/
        end

        def parse_expr_relation
          log 'parse expr relational'
          parse_expr_with_operate :parse_expr_shift, />=|<=|>|<|\binstanceof\b|\bin\b/
        end

        def parse_expr_equal
          log 'parse expr equal'
          parse_expr_with_operate :parse_expr_relation, /===|!==|==|!=/
        end
        
      end

    end
  end
end
