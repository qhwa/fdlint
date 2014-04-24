require_relative 'var'
require_relative 'if'
require_relative 'switch'
require_relative 'iter'
require_relative 'try'

module FdlintTest
  module JS
    module Stat
      
      module Stat

        include Var, If, Switch, Iter, Try

        def test_parse_statement
          js = ''
          stat = parse_js :parse_statement, js 
        end

        def test_parse_stat_block
          js = '
            {
              a = 1;
              b = 2;
              c++;
              i = i / 1;
              ;
              i++;
            }
          '
          
          stat = parse_js :parse_stat_block, js
          assert_equal 6, stat.elements.length

          assert_equal 'empty', stat.elements[4].type
        end

        def test_parse_stat_continue
          js = 'continue ; '
          stat = parse_js :parse_stat_continue, js

          assert_equal 'continue', stat.type
          assert_equal true, stat.end_with_semicolon?
          assert_equal nil, stat.left

          js = "continue\n"
          stat = parse_js :parse_stat_continue, js
          assert_equal false, stat.end_with_semicolon?
          assert_equal nil, stat.left

          js = 'continue abcde;'
          stat = parse_js :parse_stat_continue, js
          assert_equal true, stat.end_with_semicolon?
          assert_equal 'abcde', stat.left.text
        end

        def test_parse_break
          js = 'break'
          stat = parse_js :parse_stat_break, js
          assert_equal 'break', stat.type
        end

        def test_parse_stat_return
          js = 'return a + 1;'
          stat = parse_js :parse_stat_return, js

          assert_equal 'return', stat.type
          assert_equal '(+,a,1)', stat.left.text

          js = 'return;'
          stat = parse_js :parse_stat_return, js
          assert_equal nil, stat.left

          js = "return"
          stat = parse_js :parse_stat_return, js
          assert_equal false, stat.end_with_semicolon?
        end

        def test_parse_throw
          js = 'throw "assert false";'
          stat = parse_js :parse_stat_throw, js

          assert_equal 'throw', stat.type
          assert_equal '"assert false"', stat.left.text
        end

      end

    end
  end
end
