module XRay
  module JS
    module Stat
      
      module Var
        def parse_stat_var
          log 'parse stat var'

          pos = skip /var/

          decs = []
          decs << parse_stat_var_declaration 
          while check /,/
            skip /,/
            decs << parse_stat_var_declaration
          end
          
          semicolon = !!check(/;/)
          skip /\s*;|[ \t]*\n|\s*\z/, true
        
          stat = create_element VarStatement, Elements.new(decs), pos
          stat.end_with_semicolon = semicolon
          stat
        end

        def parse_stat_var_declaration 
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
