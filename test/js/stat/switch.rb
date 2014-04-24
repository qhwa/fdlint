module FdlintTest
  module JS
    module Stat
      
      module Switch
        def test_parse_stat_switch
          js = '
            switch (a) {
            case 1:
              i++;
              break;
            case 2:
              i--;
              break;
            default:
              break; 
            case 3:
              a++;
              break;
            }
          '

          stat = parse_js :parse_stat_switch, js

          assert_equal 'switch', stat.type
          assert_equal 'a', stat.expression.text
          
          block = stat.case_block
          assert_equal '[(caseclause,1,[(expression,(++,i,),),(break,,)]),(caseclause,2,[(expression,(--,i,),),(break,,)])]', block.case_clauses.text 
          assert_equal '(defaultclause,[(break,,)],)', block.default_clause.text
          assert_equal '[(caseclause,3,[(expression,(++,a,),),(break,,)])]', block.bottom_case_clauses.text
        end
      end

    end
  end
end
