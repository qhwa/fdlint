module XRay
  module JS
    module Stat
      
      module Var
        def parse_stat_var
          log 'parse stat var'
          pos = skip /var/
          decls = batch(:parse_stat_var_declaration) do
            if check(/;/)
              skip /;/
              false
            else 
              skip /,?/
              true
            end
          end

          StatementVar.new decls, pos
        end

        def parse_stat_var_declaration 
          name = parse_expr_identifier
          if check(/\=/)
            skip /\=/
            expr = scan /[^;,]+/
          else
            expr = nil
          end
          StatementVarDeclaration.new name, expr
        end
      end

    end
  end
end
