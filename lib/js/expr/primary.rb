module XRay
  module JS
    module Expr
      
      module Primary
      
        R_IDENTIFY = /[a-zA-Z_$][\w$]*/

        RESERVED_WORDS = %w(
            break case catch continue debugger default delete do else 
            finally for function if in instanceof new return switch this
            throw try typeof var void while with
            class const enum export extends import super
            implements interface let package private protected public static yield
            null true false
        )


        def parse_expr_this
          log 'parse expr this'
          ThisExpression.new scan(/this/)
        end

        def parse_expr_identifier
          log 'parse expr identifier'

          id = scan(R_IDENTIFY)
          RESERVED_WORDS.include?(id.text) ? 
              pass_error('identifier can not be reserved word') : id
        
          log "   #{id}"
          id
        end

        def parse_expr_literal
          
          LiteralExpression.new scan(/null|true|false/) 
        end

      end

    end
  end 
end
