module XRayTest
  module JS
    module Expr
      
      module Primary

        def test_parse_expr_parentheses
          js = '(12.56)'
          parser = create_parser js
          expr = parser.parse_expr_parentheses

          assert_equal '12.56', expr.text
        end

        def test_parse_expr_array
          js = '[123, 456, "hello world", /this is re/]'
          parser = create_parser js

          array = parser.parse_expr_array
          assert_equal ['123', '456', '"hello world"', '/this is re/'], 
              array.elements.collect(&:text) 
        end

        def test_parse_expr_object
          js = '{
            name: "hello 1234",
            "key 2": 123.567e12,
            12.59: 12.58,
            18: /hello/    
          }'

          parser = create_parser js
          obj = parser.parse_expr_object

          assert_equal ['name', '"key 2"', '12.59', '18'], 
              obj.elements.collect(&:name).collect(&:text)

          assert_equal ['"hello 1234"', '123.567e12', '12.58', '/hello/'],
              obj.elements.collect(&:value).collect(&:text)
        end
        
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
            '123.123e-1 = e',
            '12345.123e123'
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
            123 .12 0.123 +123e+1 123.123e-1 12345.123e123
          )
          eqs << str1 << str2 << str3 << re
          assert_equal eqs, exprs.collect(&:text)
        end

      end
    
    end
  end
end
