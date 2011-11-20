module XRayTest
  module JS
    module Expr
      
      module Expr
        def add_expr_test(jses, exprs, action)
          jses.each_with_index do |js, index|
            parser = create_parser js
            expr = parser.send action
            assert_equal exprs[index], expr.text
          end  
        end
      end

    end
  end
end
