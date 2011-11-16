module XRay
  module JS
    module Stat 
      
      module Simple
        def parse_statement
          # block
          if check /\{/
            parse_stat_block

          # empty
          elsif check /;/
            skip /;/

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
          stats = batch(:parse_statement) do
            !check(/}/)
          end 
          skip /}/ 

          BlockStatement.new stats, pos
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
