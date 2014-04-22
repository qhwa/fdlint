require_relative 'var'
require_relative 'if'
require_relative 'switch'
require_relative 'iter'
require_relative 'try'

module Fdlint
  module Parser
    module JS
      module Stat 
        
        # Stat : Statement node.
        module Stat

          include Var, If, Switch, Iter, Try

          def parse_statement
            # 在ruby-1.8下map是无序的,所以这里只能用数组来实现
            map = [
              /\{/,         'block',
              /\;/,         'empty',
              /var\b/,      'var',
              /if\b/,       'if',
              /switch\b/,   'switch',
              /do\b/,       'dowhile',
              /while\b/,    'while',
              /for\b/,      'for',
              /continue\b/, 'continue',
              /break\b/,    'break',
              /return\b/,   'return',
              /throw\b/,    'throw',
              /try\b/,      'try',
              /./,          'expression'
            ] 

            0.upto(map.size / 2 - 1) do |i|
              if check(map[i * 2])
                return self.send('parse_stat_' + map[i * 2 + 1])
              end
            end
          end

          def parse_stat_block
            log 'parse stat block'
            
            pos = skip /\{/
            stats = batch(:parse_statement, /\}/)
            skip /\}/ 

            create_element BlockStatement, Elements.new(stats), pos
          end

          def parse_stat_empty
            log 'parse stat empty'
            pos = skip /;/
            
            stat = create_element Statement, 'empty'
            stat.end_with_semicolon = true
            stat
          end

          def parse_stat_expression
            log 'parse stat expression'

            expr = parse_expression
            stat = create_element ExpressionStatement, expr
            after_parse_statement stat
          end

          def parse_stat_continue
            log 'parse stat continue'
            parse_stat_simple /continue/, :parse_expr_identifier
          end

          def parse_stat_break
            log 'parse stat break'
            parse_stat_simple /break/, :parse_expr_identifier
          end

          def parse_stat_return
            log 'parse stat return'
            parse_stat_simple /return/, :parse_expression
          end

          def parse_stat_throw
            log 'parse stat throw'
            parse_stat_simple /throw/, :parse_expression
          end

          def parse_stat_label
            log 'parse stat label'
            raise 'not impelments'
          end

          def after_parse_statement(stat)
            skip /[ \t]*/, true
            colon = !!check(/;/, true)
            stat.end_with_semicolon = colon
            colon ? skip(/;/, true) :
                (eos? || check(/\}/)) ? nil : skip(/\n/, true)
            stat
          end

          private

          def parse_stat_simple(pattern, action)
            type = scan pattern
            skip /[ \t]*/, true
            left = (eos? || check(/[;\n}]/, true)) ? nil : self.send(action)
            
            stat = create_element Statement, type.text, left, nil, type.position
            after_parse_statement stat
          end

        end
         
      end
    end
  end
end
