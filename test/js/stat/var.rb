module XRayTest
  module JS
    module Stat
      
      module Var
        def test_parse_stat_var
          js = 'var a = 1, b, c = 1 + a;' 
          expr = parse_js :parse_stat_var, js

          assert_equal 'var', expr.type

          decls = expr.declarations
          
          assert_equal 3, decls.length
          assert_equal '[(var=,a,1),(var=,b,),(var=,c,(+,1,a))]', decls.text
          assert_equal true, expr.end_with_semicolon?

          js = "var a = c++, b = c, c = 123\n a = 1 + 1"
          expr = parse_js :parse_stat_var, js
          assert_equal false, expr.end_with_semicolon?

          js = 'var a = c, b = a--'
          expr = parse_js :parse_stat_var, js
          assert_equal false, expr.end_with_semicolon?
          
          js = <<EOF 
  var rBackslash = /\\\\/g,
	rReturn = /\\r\\n/g,
	rNonWord = /\\W/;
EOF
          expr = parse_js :parse_stat_var, js
          assert_equal '(var,[(var=,rBackslash,/\\\\/g),(var=,rReturn,/\\r\\n/g),(var=,rNonWord,/\\W/)],)', expr.text
        end
      end

    end
  end
end
