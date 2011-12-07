require_relative 'base_test'

require 'js/rule/semicolon'

module XRayTest
  module JS
    module Rule
      
      class SemicolonTest < BaseTest
        include XRay::JS::Rule
        
        def test_block
          js = '{
            i = i++;   
          }'
          
          ret = visit js, 'block'
          assert_equal nil, ret
        end

        def test_empty
          ret = visit ';', 'empty'
          assert_equal nil, ret
        end

        def test_var
          js = '
            var a = 1, b = 2
            a++;
          '
          message, level = visit js, 'var'
          assert_equal :error, level
        end

        def test_expression
          js = '
            a = i + 1 + 2 + 3 * 9
            i++
          '
          message, level = visit js, 'expression'
          assert_equal :error, level 
        end

        private
        
        def visit(js, type)
          stat = parse js, :statement
          assert_equal type, stat.type

          rule = XRay::JS::Rule::Semicolon.new
          rule.visit_statement stat
        end

      end

    end
  end
end
