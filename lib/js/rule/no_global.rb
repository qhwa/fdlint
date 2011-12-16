# encoding: utf-8

module XRay
  module JS
    module Rule
      
      class NoGlobal

        def visit_program(prog)
          if @global_vars && @global_vars.length > 0 ||
              @global_funs && @global_funs.length > 0
            ['不允许使用全局变量', :error]
          end
        end
        
        def visit_stat_var(stat)
          @all_vars ||= {}
          @global_vars ||= {}
          stat.declarations.each do |decl|
            text = decl.left.text
            @all_vars[text] = true
            @global_vars[text] = true unless @closure && @closure > 0
          end
          nil
        end

        def before_parse_function_declaration
          @closure = (@closure || 0) + 1
        end

        def visit_function_declaration(fun)
          @closure -= 1
          @global_funs ||= {}
          @global_funs[fun.name.text] = true if fun.name && @closure == 0
          nil
        end

      end

    end 
  end
end
