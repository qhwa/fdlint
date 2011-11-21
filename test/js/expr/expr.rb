require_relative 'primary'
require_relative 'left_hand'
require_relative 'operate'


module XRayTest
  module JS
    module Expr
      
      module Expr

        include Primary, LeftHand, Operate

        def test_parse_expression
          jses = [
            'a = 1, b = 2, c = 3'
          ]

          exprs = [
            '(,,(,,(=,a,1),(=,b,2)),(=,c,3))'
          ]

          add_expr_test jses, exprs, :parse_expression
        end
        
        def test_parse_expr_assignment
          jses = [
            'a = 1 + 2 == 0 ? 1 : 0',
            'a *= 1 + 2'
          ]

          exprs = [
            '(=,a,(==,(+,1,2),0) ? 1 : 0)',
            '(*=,a,(+,1,2))'
          ]

          add_expr_test jses, exprs, :parse_expr_assignment

        end

        def test_parse_expr_condition
          jses = [
            'a + 1 == 0 ? 1 : 2'
          ]

          exprs = [
            '(==,(+,a,1),0) ? 1 : 2'
          ]

          add_expr_test jses, exprs, :parse_expr_condition
        end

        protected

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
