module XRay
  module JS
    module Stat
      
      module Var
        def parse_stat_var
          log 'parse stat var'
          pos = skip /var/
          decls = batch(:parse_stat_var_declaration, /;/, /,/)
          skip /;/
          VarStatement.new decls, pos
        end

        def parse_stat_var_declaration 
          name = parse_expr_identifier
          expr = if check(/\=/)
            skip /\=/
            parse_expr_assignment
          end
          VarStatementDeclaration.new name, expr
        end
      end

    end
  end
end
