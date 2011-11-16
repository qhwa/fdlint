module XRayTest
  module JS
    module Expr
      
      module Primary
        
        def test_parse_expr_this
          js = 'this.a = hello'
          
          parser = create_parser(js)
          this_expr = parser.parse_expr_this

          assert_equal 'this', this_expr.text
        end

      end
    
    end
  end
end
