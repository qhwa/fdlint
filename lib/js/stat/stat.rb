require_relative 'var'
require_relative 'if'
require_relative 'iter'

module XRay
  module JS
    module Stat 
      
      module Stat

        include Var, If, Iter

        def parse_statement
          if check /\{/
            parse_stat_block

          elsif check /;/
            parse_stat_empty

          elsif check /var\s/
            parse_stat_var

          elsif check /if\b/
            parse_stat_if

          elsif check /do\b/
            parse_stat_dowhile

          elsif check /while\b/
            parse_stat_while

          elsif check /for\b/
            parse_stat_for

          elsif check /continue\b/
            parse_stat_continue

          else
            parse_stat_expression
          end
        end

        def parse_stat_block
          log 'parse stat block'
          
          pos = skip /\{/
          stats = batch(:parse_statement, /}/)
          skip /}/ 

          create_element BlockStatement, Elements.new(stats), pos
        end

        def parse_stat_empty
          log 'parse stat empty'
          pos = skip /;/
          
          create_element Statement, 'empty'
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

        private

        def parse_stat_simple(pattern, action)
          type = scan pattern
          skip /[ \t]*/, true
          left = (eos? || check(/[;\n]/, true)) ? nil : self.send(action)
          
          stat = create_element Statement, type.text, left, nil, type.position
          after_parse_statement stat
        end

        def after_parse_statement(stat)
          skip /[ \t]*/, true
          colon = !!check(/;/, true)
          stat.end_with_semicolon = colon
          colon ? skip(/;/, true) :
              !eos? ? skip(/\n/, true) : nil
          stat
        end

      end
       
    end
  end
end
