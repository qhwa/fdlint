module XRay
  module JS
    module Expr 

      module Simple 
        
        R_IDENTIFY = /[a-zA-Z_$][\w$]*/
        RESERVED_WORDS = %w(
            break case catch continue debugger default delete do else 
            finally for function if in instanceof new return switch this
            throw try typeof var void while with
            class const enum export extends import super
            implements interface let package private protected public static yield
            null true false
        )

        def parse_expression
          parse_expr_simple
        end

        def parse_expr_simple
          log 'parse expression'

          expr = scan /[^;]*/
          expr = SimpleExpression.new(expr.text, expr.position)
          log expr.text
          expr
        end

        def parse_expr_identifier
          log 'parse expr identifier'

          id = scan(R_IDENTIFY)
          RESERVED_WORDS.include?(id.text) ? 
              pass_error('identifier can not be reserved word') : id
        
          log "   #{id}"
          id
      end
         
      end

    end
  end
end
