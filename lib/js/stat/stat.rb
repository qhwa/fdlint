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

          stat.end_with_semicolon = !!check(/;/)

          skip /\s*;|[ \t]*\n|\s*\z/, true
          
          stat
        end


      end
       
    end
  end
end
