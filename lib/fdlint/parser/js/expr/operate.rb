module Fdlint
  module Parser
    module JS
      module Expr
        
        module Operate
       
          def parse_expr_postfix
            log 'parse expr postfix'
            expr = parse_expr_lefthand
            if check(/[ \t]*(?:\+\+|--)/, true)
              op = scan /\+\+|--/
              expr = create_element Expression, op.text, expr
            end
            expr
          end

          def parse_expr_unary
            log 'parse expr unary'
            r = /delete|void|typeof|\+\+|--|\+|-|~|!/
            if check r
              op = scan r
              create_element Expression, op.text, nil, parse_expr_unary, scanner_pos
            else
              parse_expr_postfix
            end
          end

          def parse_expr_mul
            log 'parse expr mul'
            parse_expr_with_operate :parse_expr_unary, /(?:\*|\/|%)(?!=)/
          end

          def parse_expr_add
            log 'parse expr add'
            parse_expr_with_operate :parse_expr_mul, /(?:\+|-)(?!=)/
          end

          def parse_expr_shift
            log 'parse expr shift'
            parse_expr_with_operate :parse_expr_add, /(?:<<|>>>|>>)(?!=)/
          end

          def parse_expr_relation
            not_in = expr_operate_not_in?
            log "parse expr relational#{not_in ? '(notin)' : ''}"
            pattern = not_in ? (/>=|<=|>|<|\binstanceof\b/) : (/>=|<=|>|<|\binstanceof\b|\bin\b/)
            parse_expr_with_operate :parse_expr_shift, pattern 
          end

          def parse_expr_equal
            log 'parse expr equal'
            parse_expr_with_operate :parse_expr_relation, /===|!==|==|!=/
          end

          def parse_expr_bit_and
            log 'parse expr bit and'
            parse_expr_with_operate :parse_expr_equal, /&(?![&=])/
          end

          def parse_expr_bit_xor
            log 'parse expr bit xor'
            parse_expr_with_operate :parse_expr_bit_and, /\^(?!=)/
          end

          def parse_expr_bit_or
            log 'parse expr bit or'
            parse_expr_with_operate :parse_expr_bit_xor, /\|(?![|=])/
          end

          def parse_expr_logical_and
            log 'parse expr logical and'
            parse_expr_with_operate :parse_expr_bit_or, /&&/
          end

          def parse_expr_logical_or
            log 'parse expr logical or'
            parse_expr_with_operate :parse_expr_logical_and, /\|\|/
          end

          def expr_operate_not_in?
            @operate_not_in || false
          end

          def expr_operate_not_in=(value)
            @operate_not_in = !!value
          end
          
        end

      end
    end
  end
end
