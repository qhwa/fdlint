# encoding: utf-8

module XRay
  module JS
    module Rule
      
      class NoGlobal

        def visit_program(prog)
          @scopes ||= []
          global_scope = @scopes[0] || []
          
          global_scope.collect do |elm|
            message = elm.type == 'var' ? '不允许使用全局变量' :
                elm.type == 'function' ? '不允许申明全局函数' : 'assert fail' 
            VisitResult.new(elm, message, :error)
          end
        end
        
        def visit_stat_var(stat)
          scope = current_scope
          stat.declarations.each do |dec|
            scope << dec
          end
          nil
        end

        def before_parse_function_declaration(*args)
          @scope_index = (@scope_index || 0) + 1
        end

        def visit_function_declaration(fun)
          @scope_index -= 1
          current_scope << fun if fun.name
          nil
        end

        private

        def current_scope
          @scopes ||= []
          @scope_index ||= 0
          @scopes[@scope_index] ||= []
        end

      end

    end 
  end
end
