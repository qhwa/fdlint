# encoding: utf-8

module XRay
  module JS
    module Rule
      
      class NoGlobalRule
        
        def visit_stat_var(stat)
          unless @scope_index > 0
            ['不允许使用全局变量', :error] 
          end
        end

        def visit_stat_var_declaration(dec)
          scope = current_scope
          scope << dec.left.text
          nil
        end 

        def visit_function_name(name)
          current_scope << name.text 
          ['不允许申明全局函数', :error] if @scope_index == 0
        end

        def visit_function_parameters(params)
          @scope_index = (@scope_index || 0) + 1
          scope = current_scope(true)
          params.each do |param|
            scope << param.text
          end
          nil
        end

        def visit_stat_for(stat)
          first = stat.condition.first
          nil
        end

        def visit_function_declaration(fun)
          @scope_index -= 1
          nil
        end

        def visit_expr_assignment(expr)
          if expr.type == '='
            id = find_assignment_id(expr.left)

            if id && use_id_global?(id.text)
              ['禁止使用未定义的变量(或全局变量)', :error] 
            end
          end
        end

        private

        def current_scope(empty = false)
          @scopes ||= []
          @scope_index ||= 0
          @scopes[@scope_index] = [] if empty
          @scopes[@scope_index] ||= []
        end

        def find_assignment_id(expr)
          expr.type == 'id' ? expr :  
            expr.type == '.' && expr.left.text == 'window' &&
              expr.right.type == 'id' ? expr.right : nil
        end

        def use_id_global?(id)
          white_list = %w(ImportJavscript)

          return false if white_list.include? id
          return true unless @scopes && @scope_index

          @scope_index.downto(0) do |index|
            scope = @scopes[index]
            return false if scope && scope.find { |name| name == id}
          end 
          true
        end

      end

    end 
  end
end
