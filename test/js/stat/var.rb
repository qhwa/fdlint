module XRayTest
  module JS
    module Stat
      
      module Var
        def test_parse_stat_var
          js = 'var a, i = 1, j = 2, k = i + j;'

          parser = create_parser(js)

          var = parser.parse_stat_var
          decls = var.declarations

          assert_equal 4, decls.length

          assert_equal 'a', decls[0].name.text

          assert_equal 'i', decls[1].name.text
          assert_equal '1', decls[1].expression.text
          
          assert_equal 'k', decls[3].name.text
          assert_equal 'i + j', decls[3].expression.text
        end
      end

    end
  end
end
