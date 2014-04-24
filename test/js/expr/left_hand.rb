module FdlintTest
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

          add_test :parse_expr_member, jses, exprs 
        end 
         
      end

    end
  end
end
