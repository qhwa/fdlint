# encoding: utf-8

module XRay
  module JS
    module Rule
      
      class NoGlobal
        
        def visit_stat_var(stat)
          scope = current_scope
          stat.declarations.each do |dec|
            scope << dec
          end
          ['不允许使用全局变量', :error] if @scope_index == 0
        end

        def before_parse_function_declaration(*args)
          @scope_index = (@scope_index || 0) + 1
        end

        def visit_function_declaration(fun)
          @scope_index -= 1
          if fun.name
            current_scope << fun
            ['不允许申明全局函数', :error] if @scope_index == 0 
          end
        end

        def visit_expr_assignment(expr)
          if expr.type == '='
            puts "here #{expr}"
            id = find_assignment_id(expr.left)
            unless check_assignment_id id
              ['禁止使用未定义的变量(或全局变量)', :error] 
            end
          end
        end

        private

        def current_scope
          @scopes ||= []
          @scope_index ||= 0
          @scopes[@scope_index] ||= []
        end

        def find_assignment_id(expr)
          if expr.type == 'id'
            expr
          elsif expr.type == '.' && expr.left.text == 'window' &&
              expr.right.type == 'id'
            expr.right
          end
        end

        def check_assignment_id(id)
          unless @scope_index
            return false
          end

          text = id.text

          @scope_index.downto(0) do |index|
            scope = @scopes[index]
            return true if scope && scope.find { |elm| elm.left.text == text }
          end 
          false
        end

      end

    end 
  end
end
