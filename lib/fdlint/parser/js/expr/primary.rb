module Fdlint
  module Parser
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
          R_HEX = /0[xX]/
          R_NUMBERIC = /[+-]?(?:\d|(?:[.]\d))/
          R_STRING = /['"]/
          R_REGEXP = /\/[^\/]/

          def parse_expr_primary
            log "parse expr primary"
            if check /\(/
              parse_expr_parentheses

            elsif check /\[/
              parse_expr_array

            elsif check /\{/
              parse_expr_object
          
            # literal 
            elsif check R_THIS_NULL_BOOLEAN 
              parse_expr_literal_this_null_boolean

            elsif check R_HEX
              parse_expr_literal_hex

            elsif check R_NUMBERIC
              parse_expr_literal_number

            elsif check R_STRING
              parse_expr_literal_string

            elsif check R_REGEXP
              parse_expr_literal_regexp
            #~
            
            else
              parse_expr_identifier
            end
          end

          def parse_expr_parentheses
            debug { 'parse expr parentheses' }

            pos = skip /\(/
            expr = parse_expression
            skip /\)/
            
            create_expression 'parentheses', expr, pos
          end

          def parse_expr_array
            debug { 'parse expr array' }

            pos = skip /\[/
            elms = batch(:parse_expr_assignment, /\]/, /,/)
            skip /\]/

            create_expression 'array', Elements.new(elms), pos 
          end

          def parse_expr_object
            debug { 'parse expr object' }

            pos = skip /\{/
            elms = batch(:parse_expr_object_item, /\}/, /,/)
            skip /\}/

            create_expression 'object', Elements.new(elms), pos
          end

          def parse_expr_object_item
            debug { 'parse expr object item' }

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
            debug { 'parse expr identifier' }

            id = scan(R_IDENTIFY)
            RESERVED_WORDS.include?(id.text) ? 
                parse_error("identifier can not be reserved word: #{id}") : id
          
            create_expression 'id', id
          end

          def parse_expr_literal_this_null_boolean
            debug { 'parse expr literal this null boolean' }
            expr = scan /this|null|true|false/
            type = expr.text.gsub(/true|false/, 'boolean')

            create_expression type, expr 
          end

          def parse_expr_literal_string
            debug { 'parse expr literal string' }

            expr = if check /'/
              scan /'(?:(?:\\')|(?:\\\n)|[^'\n])*'/
            elsif check /"/
              scan /"(?:(?:\\")|(?:\\\n)|[^"\n])*"/
            else
              raise 'assert false'
            end

            create_expression 'string', expr 
          end

          def parse_expr_literal_hex
            debug { 'parse expr literal hex' }
            expr = scan /0[xX][0-9a-fA-F]+/
            create_expression 'number', expr
          end

          def parse_expr_literal_number
            debug { 'parse expr literal number' }
            expr = scan /[+-]?(?:(?:\d*[.]\d+)|(?:\d+))(?:[eE][+-]?\d+)?/
            create_expression 'number', expr
          end

          def parse_expr_literal_regexp
            debug { 'parse expr literal regexp' }
            expr = scan %r{/(?:(?:\\.)|(?:\[(?:\\.|[^\[\]])+\])|[^/\\])+/[a-z]*}
            create_expression 'regexp', expr
          end

          private

          def create_expression(*args)
            expr = PrimaryExpression.new *args
            debug { "  #{expr}" }
            expr
          end

        end

      end
    end 
  end
end
