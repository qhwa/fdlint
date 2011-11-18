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

        R_NULL_BOOLEAN = /(?:this|null|true|false)\b/
        R_NUMBERIC = /[+-]?(?:\d|(?:[.]\d))/
        R_STRING = /['"]/
        R_REGEXP = /\//

        def parse_expr_primary
          # (expression)
          if check /\(/
            parse_expr_parentheses

          elsif check /\[/
            parse_expr_array

          elsif check /\{/
            parse_expr_object

          elsif check_expr_literal
            parse_expr_literal
          end
        end

        def parse_expr_parentheses
          log 'parse expr parentheses'

          skip /\(/
          expr = parse_expression
          skip /\)/
          expr
        end

        def parse_expr_array
          log 'parse expr array'

          pos = skip /\[/
          elms = batch(:parse_expr_assignment, /]/, /,/)
          skip /]/
          
          ArrayLiteral.new elms, pos
        end

        def parse_expr_object
          log 'parse expr object'
        end

        def parse_expr_identifier
          log 'parse expr identifier'

          id = scan(R_IDENTIFY)
          RESERVED_WORDS.include?(id.text) ? 
              pass_error('identifier can not be reserved word') : id
        
          log "  #{id}"
          id
        end

        def parse_expr_literal
          log 'parse expr literal'

          expr = if check R_NULL_BOOLEAN 
            scan /this|null|true|false/
          elsif check R_NUMBERIC
            scan /[+-]?(?:(?:\d*[.]\d+)|(?:\d+))(?:[eE][+-]\d+)?/
          elsif check /'/ # single quot string
            scan /'(?:(?:\\')|(?:\\\n)|[^'\n])*'/
          elsif check /"/ # double quot string
            scan /"(?:(?:\\")|(?:\\\n)|[^"\n])*"/
          elsif check R_REGEXP
            scan %r{/(?:(?:\\/)|[^/])+/[a-z]*} 
          else
            raise 'assert false'
          end

          log "  #{expr}"
          
          Expression.new expr
        end

        protected

        def check_expr_primary
          check /\(/ or
              check_expr_literal 
        end

        def check_expr_literal
          check R_NULL_BOOLEAN or 
              check R_NUMBERIC or
              check R_STRING or
              check R_REGEXP
        end

        private

        def parse_assignment_elements()
          
        end

      end

    end
  end 
end
