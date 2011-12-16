# encoding: utf-8

module XRay
  module JS
    module Rule
      
      class NoGlobal

        def visit_program(prog)
          ret = []
          @global_vars && @global_vars.each do |var|
            ret << VisitResult.new(var, '不允许使用全局变量', :error)
          end

          @global_funs && @global_funs.each do |fun|
            ret << VisitResult.new(fun, '不允许申明全局函数', :error)
          end

          ret
        end
        
        def visit_stat_var(stat)
          @all_vars ||= []
          @global_vars ||= [] 
          stat.declarations.each do |dec|
            @all_vars << dec
            @global_vars << dec unless @closure && @closure > 0
          end
          nil
        end

        def before_parse_function_declaration(*args)
          @closure = (@closure || 0) + 1
        end

        def visit_function_declaration(fun)
          @closure -= 1
          @global_funs ||= []
          @global_funs << fun if fun.name && @closure == 0
          nil
        end

      end

    end 
  end
end
