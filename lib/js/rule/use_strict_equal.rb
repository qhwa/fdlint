# encoding: utf-8

module XRay
  module JS
    module Rule
     
      class UseStrictEqual 

        def visit_expr_equal(expr)
          if expr.type == '==' || expr.type == '!='
            ['避免使用==和!=操作符', :warn]
          end
        end
         
      end

    end
  end
end
