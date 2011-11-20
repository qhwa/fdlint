module XRayTest
  module JS
    module Expr
      
      module Postfix
        
        def test_parse_expr_postfix
          jses = [
            'hello++'
          ]
          eqs = [
            '(++,hello,)'
          ]

          jses.each_with_index do |js, index|
            parser = create_parser js
            expr = parser.parse_expr_postfix

            assert_equal eqs[index], expr.text
          end
        end

      end

    end
  end
end
