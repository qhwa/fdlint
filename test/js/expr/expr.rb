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

          add_test :parse_expression, jses, exprs 
        end
        
        def test_parse_expr_assignment
          jses = [
            'a = 1 + 2 == 0 ? 1 : 0',
            'a *= 1 + 2'
          ]

          exprs = [
            '(=,a,(?:,(==,(+,1,2),0),1,0))',
            '(*=,a,(+,1,2))'
          ]

          add_test :parse_expr_assignment, jses, exprs 

        end

        def test_parse_expr_condition
          jses = [
            'a + 1 == 0 ? 1 : 2'
          ]

          exprs = [
            '(?:,(==,(+,a,1),0),1,2)'
          ]

          add_test :parse_expr_condition, jses, exprs 
        end

      end

    end
  end
end
