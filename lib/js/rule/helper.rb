module XRay
  module JS
    module Rule
      
      module Helper
        def find_expr_member(expr)
          while expr.is_a?(Expression) && !yield(expr) 
            expr = expr.left
          end
          expr && expr.is_a?(Expression) && yield(expr) ? expr : nil
        end
      end

    end
  end
end
