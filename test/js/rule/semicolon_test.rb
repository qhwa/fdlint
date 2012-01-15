# encoding: utf-8
require_relative 'base_test'

require 'js/rule/checklist'

module XRayTest
  module JS
    module Rule
      
      class SemicolonTest < BaseTest
        include XRay::JS::Rule

        def setup
          @msg = '所有语句结束带上分号'
        end
        
        def test_block
          js = '{
            i = i++;   
          }'
          
          ret = visit js, 'block'
          assert_equal [], ret
        end

        def test_empty
          ret = visit ';', 'empty'
          assert_equal [], ret
        end

        def test_var
          js = '
            var a = 1, b = 2
            a++;
          '
          ret = visit js, 'var'
          assert_equal [[@msg, :error]], ret
        end

        def test_expression
          js = '
            a = i + 1 + 2 + 3 * 9
            i++
          '
          ret = visit js, 'expression'
          assert_equal [[@msg, :error]], ret
        end

        private
        
        def visit(js, type)
          stat = parse js, :statement
          assert_equal type, stat.type

          rule = XRay::JS::Rule::Checklist.new
          rule.visit_statement stat
        end

      end

    end
  end
end
