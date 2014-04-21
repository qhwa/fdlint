module Fdlint
  module Parser
    module JS
      module Stat
        
        module Try
          def parse_stat_try
            pos = skip /try/
            try_part = parse_stat_block

            catch_part = if check /catch\b/
              catch_pos = skip /catch\s*\(/
              id = parse_expr_identifier
              skip /\)/
              create_element Statement, 'catch', id, parse_stat_block, catch_pos
            end
            
            finally_part = if check /finally\b/
              skip /finally/
              parse_stat_block
            end

            create_element TryStatement, try_part, catch_part, finally_part, pos
          end
        end

      end
    end
  end
end
