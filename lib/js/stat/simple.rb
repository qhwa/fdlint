module XRay
  module JS
    module Stat 
      
      module Simple
        def parse_statement
          if check /\{/
            parse_stat_block
          else
            parse_stat_simple
          end
        end

        def parse_stat_simple
          log 'parse stat simple'

          stat = scan /[^;]*/
          stat = Statement.new(stat.text, stat.position)
          skip /;/
          log stat.text
          stat
        end

        def parse_stat_block
          log 'parse stat block'
          
          pos = skip /\{/
          stats = batch(:parse_statement) do
            !check(/}/)
          end 
          skip /}/ 

          StatementBlock.new stats, pos
        end
      end
       
    end
  end
end
