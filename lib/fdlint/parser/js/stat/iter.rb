module Fdlint
  module Parser
    module JS
      module Stat
        
        # 循环语句
        module Iter

          def parse_stat_dowhile
            debug { 'parse stat dowhile' }

            pos = skip /do/
            body = parse_statement

            skip /while\s*\(/
            condition = parse_expression
            skip /\)/ 
            
            create_element DowhileStatement, body, condition, pos
          end 

          def parse_stat_while
            debug { 'parse stat while' }

            pos = skip /while\s*\(/
            condition = parse_expression
            skip /\)/
            body = parse_statement

            create_element WhileStatement, condition, body, pos
          end

          def parse_stat_for
            debug { 'parse stat for' }

            pos = skip /for/
            
            con_pos = skip /\(/
            first, is_var = parse_stat_for_con_first
            type, second, third = parse_stat_for_con_other(first, is_var)
            skip /\)/

            condition = create_element ForConditionElement, type, first, second, third, con_pos
            body = parse_statement
            create_element ForStatement, condition, body, pos
          end

          private

          def parse_stat_for_con_first
            self.expr_operate_not_in = true
            first = if check /var\b/
              skip /var/
              is_var = true 
              parse_stat_var_declarationlist
            elsif !check(/;/)
              parse_expression 
            end
            self.expr_operate_not_in = false
            [first, is_var]
          end

          def parse_stat_for_con_other(first, is_var)
            if check /in\b/
              if is_var && first.length != 1 || !is_var && !first.left_hand?
                parse_error('first expression of for-condtion error')
              end

              skip /in/
              type = is_var ? 'forvarin' : 'forin'
              second = parse_expression
            else
              skip /;/
              type = is_var ? 'forvar' : 'fordefault'
              second = check(/;/) ? nil : parse_expression
              skip /;/

              third = check(/\)/) ? nil : parse_expression
            end
            [type, second, third]
          end

        end

      end
    end
  end
end
