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

        R_THIS_NULL_BOOLEAN = /(?:this|null|true|false)\b/
        R_NUMBERIC = /[+-]?(?:\d|(?:[.]\d))/
        R_STRING = /['"]/
        R_REGEXP = /\//

        def parse_expr_primary
          if check /\(/
            parse_expr_parentheses

          elsif check /\[/
            parse_expr_array

          elsif check /\{/
            parse_expr_object

          elsif check_expr_literal
            parse_expr_literal

          else
            parse_expr_identifier
          end
        end

        def parse_expr_parentheses
          log 'parse expr parentheses'

          pos = skip /\(/
          expr = parse_expression
          skip /\)/
          
          PrimaryExpression.new '()', expr, pos
        end

        def parse_expr_array
          log 'parse expr array'

          pos = skip /\[/
          elms = batch(:parse_expr_assignment, /]/, /,/)
          skip /]/
         
          PrimaryExpression.new '[]', Elements.new(elms), pos 
        end

        def parse_expr_object
          log 'parse expr object'

          pos = skip /\{/
          elms = batch(:parse_expr_object_item, /}/, /,/)
          skip /}/
          
          PrimaryExpression.new '{}', Elements.new(elms), pos
        end

        def parse_expr_object_item
          log 'parse expr object item'

          name = if check R_STRING
            parse_expr_literal_string
          elsif check R_NUMBERIC
            parse_expr_literal_number
          else
            parse_expr_identifier
          end

          skip /:/
          value = parse_expr_assignment
          
          Expression.new ':', name, value
        end

        def parse_expr_identifier
          log 'parse expr identifier'

          id = scan(R_IDENTIFY)
          RESERVED_WORDS.include?(id.text) ? 
              pass_error('identifier can not be reserved word') : id
        
          log "  #{id}"

          PrimaryExpression.new 'id', id
        end

        def parse_expr_literal
          if check R_THIS_NULL_BOOLEAN 
            parse_expr_literal_this_null_boolean
          elsif check R_NUMBERIC
            parse_expr_literal_number
          elsif check R_STRING
            parse_expr_literal_string
          elsif check R_REGEXP
            parse_expr_literal_regexp
          else
            raise 'assert false'
          end
        end

        def parse_expr_literal_this_null_boolean
          log 'parse expr literal this null boolean'
          expr = scan /this|null|true|false/
          log "  #{expr}"
          type = expr.text.gsub(/true|false/, 'boolean')

          PrimaryExpression.new type, expr 
        end

        def parse_expr_literal_string
          log 'parse expr literal string'

          expr = if check /'/
            scan /'(?:(?:\\')|(?:\\\n)|[^'\n])*'/
          elsif check /"/
            scan /"(?:(?:\\")|(?:\\\n)|[^"\n])*"/
          else
            raise 'assert false'
          end

          log "  #{expr}"

          PrimaryExpression.new 'string', expr 
        end

        def parse_expr_literal_number
          log 'parse expr literal number'
          expr = scan /[+-]?(?:(?:\d*[.]\d+)|(?:\d+))(?:[eE][+-]?\d+)?/
          
          log "  #{expr}"

          PrimaryExpression.new 'number', expr
        end

        def parse_expr_literal_regexp
          log 'parse expr literal regexp'
          expr = scan %r{/(?:(?:\\/)|[^/])+/[a-z]*}
          log "  #{expr}"
          PrimaryExpression.new 'regexp', expr
        end

        protected

        def check_expr_literal
          check R_THIS_NULL_BOOLEAN or 
              check R_NUMBERIC or
              check R_STRING or
              check R_REGEXP
        end

      end

    end
  end 
end
