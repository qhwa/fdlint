module Fdlint
  module Parser
    module JS
      module Stat
        
        module Switch
          def parse_stat_switch
            log 'parse stat switch'

            pos = skip /switch\s*\(/
            expression = parse_expression
            skip /\)/
            block = parse_stat_caseblock
            
            create_element SwitchStatement, expression, block, pos
          end

          def parse_stat_caseblock
            log 'parse stat caseblock'

            pos = skip /\{/
            case_clauses = check(/case\b/) ? parse_stat_caseclauses : nil
            default_clause = check(/default\b/) ? parse_stat_defaultclause : nil
            bottom_case_clauses = check(/case\b/) ? parse_stat_caseclauses : nil
            skip /\}/

            create_element CaseBlockStatement, case_clauses, default_clause, 
                bottom_case_clauses, pos
          end

          def parse_stat_caseclauses
            log 'parse stat caseclauses'
            stats = batch(:parse_stat_caseclause, /default\b|\}/)
            create_element Elements, stats 
          end

          def parse_stat_caseclause
            log 'parse stat caseclause'

            pos = skip /case/
            expr = parse_expression
            skip /:/
            stats = parse_statement_list
            create_element Statement, 'caseclause', expr, stats, pos
          end

          def parse_stat_defaultclause
            log 'parse stat defaultclause'

            pos = skip /default\s*:/
            stats = parse_statement_list 
            create_element Statement, 'defaultclause', stats, nil, pos
          end

          private

          def parse_statement_list
            elms = batch(:parse_statement, /case\b|default\b|\}/)
            Elements.new elms
          end

        end

      end
    end
  end
end
