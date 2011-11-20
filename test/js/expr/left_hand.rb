module XRayTest
  module JS
    module Expr
      
      module LeftHand
      
        def test_parse_expr_member
          jses = [
            'abc[123].bcd[hello]["hello"]',
            'abc(1, abc, "hello", /hello/, 11.10)[hello].abc["bcd"](1, 2, 3)'
          ]

          exprs = [
            '([,([,(.,([,abc,123),bcd),hello),"hello")',
            '((,([,(.,([,((,abc,[1,abc,"hello",/hello/,11.10]),hello),abc),"bcd"),[1,2,3])'
          ]

          add_expr_test jses, exprs, :parse_expr_member
        end 
         
      end

    end
  end
end
