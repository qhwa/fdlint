module FdlintTest
  module JS
    module Stat
      
      module Iter

        def test_parse_stat_dowhile
          js = '
           do {
            i++;    
           } while (x === 0 || x >= 1)
          '

          stat = parse_js :parse_stat_dowhile, js
          assert_equal 'dowhile', stat.type

          assert_equal '(block,[(expression,(++,i,),)],)', stat.body.text
          assert_equal '(||,(===,x,0),(>=,x,1))', stat.condition.text
        end

        def test_parse_stat_while
          js = '
            while (i++ < 100) {
              alert("hello"); 
              i++;
            }
          '

          stat = parse_js :parse_stat_while, js

          assert_equal 'while', stat.type
          assert_equal '(<,(++,i,),100)', stat.condition.text
          assert_equal '(block,[(expression,((,alert,["hello"]),),(expression,(++,i,),)],)', 
              stat.body.text
        end

        def test_parse_stat_for
          test_parse_stat_fordefault
          test_parse_stat_forvar
          test_parse_stat_forvarin
          test_parse_stat_forin
        end

        private

        def test_parse_stat_fordefault
          js = '
            for (i = 0; i < 10; i++) {
              hello(i);    
            }
          '

          stat = parse_js :parse_stat_for, js
          assert_equal 'for', stat.type
          
          con = stat.condition
          assert_equal 'fordefault', con.type
          assert_equal '(=,i,0)', con.first.text
          assert_equal '(<,i,10)', con.second.text
          assert_equal '(++,i,)', con.third.text
        end 

        def test_parse_stat_forvar
          js = '
            for (var i = 1; i < 10; i++) {
              hello(i)    
            }
          '

          stat = parse_js :parse_stat_for, js
          con = stat.condition

          assert_equal 'forvar', con.type
          assert_equal '[(var=,i,1)]', con.first.text
          assert_equal '(<,i,10)', con.second.text
          assert_equal '(++,i,)', con.third.text
        end

        def test_parse_stat_forvarin
          js = '
            for (var k in o) {
              alert(o[k]);    
            }
          '
          
          stat = parse_js :parse_stat_for, js
          con = stat.condition

          assert_equal 'forvarin', con.type
          assert_equal '[(var=,k,)]', con.first.text
          assert_equal 'o', con.second.text
          assert_equal nil, con.third
        end

        def test_parse_stat_forin
          js = '
            for (k in o) {
              alert(o[k]);    
            }
          '
          
          stat = parse_js :parse_stat_for, js
          con = stat.condition

          assert_equal 'forin', con.type
          assert_equal 'k', con.first.text
          assert_equal 'o', con.second.text
          assert_equal nil, con.third
        end
        
      end

    end
  end
end
