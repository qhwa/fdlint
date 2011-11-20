module XRayTest
  module JS
    module Expr
      
      module LeftHand
      
        def test_parse_expr_member
          jses = [
            'abc[123].bcd[hello]["hello"]',
            'abc(1, abc, "hello", /hello/, 11.10)[hello].abc["bcd"](1, 2, 3)'
          ]

          eqs = [
            '([,([,(.,([,abc,123),bcd),hello),"hello")',
            '((,([,(.,([,((,abc,[1,abc,"hello",/hello/,11.10]),hello),abc),"bcd"),[1,2,3])'
          ]
          
          jses.each_with_index do |js, index|
            parser = create_parser js
            expr = parser.parse_expr_member
            assert_equal eqs[index], expr.text 
          end
        end 
         
      end

    end
  end
end
