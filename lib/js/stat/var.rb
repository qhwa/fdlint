module XRay
  module JS
    module Stat
      
      module Var
        def parse_stat_var
          log 'parse stat var'

          pos = skip /var/

          decs = parse_stat_var_declarationlist
          stat = create_element VarStatement, decs, pos
          stat.end_with_semicolon = !!check(/;/)
          
          skip /\s*;|[ \t]*\n|\s*\z/, true
          stat
        end

        def parse_stat_var_declarationlist
          log 'parse stat var declarationlist'
          decs = []
          decs << parse_stat_var_declaration 
          while check /,/
            skip /,/
            decs << parse_stat_var_declaration
          end
          create_element Elements, decs
        end

        def parse_stat_var_declaration 
          log 'parse stat var declaration'
          name = parse_expr_identifier
          expr = if check(/\=/)
            skip /\=/
            parse_expr_assignment
          end
          create_element Statement, 'var=', name, expr
        end
      end

    end
  end
end
