module XRayTest
  module JS
    module Expr
      
      module Primary
        
        def test_parse_expr_literal
          jses = [
            'this.a = 123',
            'null === a',
            'true === false',
            'false === true',

            '123 == a',
            '.12 = b',
            '0.123 = c',
            '+123e+1 = d',
            '123.123e-1 = e'
          ]

          str1 = %q("hello this is a single line str\\"ing")
          str2 = %q('hello this is a \'single line string')

          str3 = '"hello this is an mutiline string\\
          hello this is an mutiline string\\
          hello this is an mutiline string"'

          re = %q{/((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^\[\]]*\]|['"][^'"]*['"]|[^\[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g}

          jses << str1 << str2 << str3 << re

          exprs = jses.collect do |js|
            parser = create_parser js
            parser.parse_expr_literal
          end

          eqs = %w(
            this null true false
            123 .12 0.123 +123e+1 123.123e-1
          )
          eqs << str1 << str2 << str3 << re
          assert_equal eqs, exprs.collect(&:text)
        end

      end
    
    end
  end
end
