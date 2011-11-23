module XRay
  module JS
    module Stat

      module If
        def parse_stat_if
          log 'parse stat if'

          pos = skip /if\s*\(/
          condition = parse_expression
          skip /\)/

          true_part = parse_statement
          false_part = if check /else\b/
            skip /else/
            parse_statement
          end
          
          create_element IfStatement, condition, true_part, false_part, pos
        end
      end

    end
  end
end
