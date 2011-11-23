require_relative 'var'
require_relative 'if'
require_relative 'iter'

module XRayTest
  module JS
    module Stat
      
      module Stat

        include Var, If, Iter

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
          
          expr = parse_js :parse_stat_block, js
          assert_equal 6, expr.elements.length

          assert_equal 'empty', expr.elements[4].type
        end
      end

    end
  end
end
