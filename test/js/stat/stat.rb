require_relative 'var'

module XRayTest
  module JS
    module Stat
      
      module Stat

        include Var

        def test_parse_stat_block
          js = '
            {
              a = 1;
              b = 2;
              c++;
              i = i / 1;    
            }
          '
          expr = '(block,[(=,a,1);,(=,b,2);,(++,c,);,(=,i,(/,i,1));],)'
          
        end
      end

    end
  end
end
