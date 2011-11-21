require_relative 'var'

module XRay
  module JS
    module Stat 
      
      module Stat

        include Var

        def parse_statement
          # block
          if check /\{/
            parse_stat_block

          # empty
          elsif check /;/
            parse_stat_empty

          # var
          elsif check /var\s/
            parse_stat_var

          # expression 
          else
            parse_stat_expression
          end
        end

        def parse_stat_block
          log 'parse stat block'
          
          pos = skip /\{/
          stats = batch(:parse_statement, /}/)
          skip /}/ 

          BlockStatement.new stats, pos
        end

        def parse_stat_empty
          log 'parse stat empty'
          pos = skip /;/
          EmptyStatement.new(pos)
        end

        def parse_stat_expression
          log 'parse stat expression'
          expr = parse_expression
          skip /;/
          ExpressionStatement.new expr 
        end

      end
       
    end
  end
end
