module FdlintTest
  module JS
    module Stat

      module If
        def test_parse_stat_if
          js = '
            if (a === b && c === d) {
              hello("alibaba");    
            } else {
              other("taobao");    
            }
          ' 

          stat = parse_js :parse_stat_if, js

          assert_equal 'if', stat.type
          assert_equal '(&&,(===,a,b),(===,c,d))', stat.condition.text
          assert_equal '(block,[(expression,((,hello,["alibaba"]),)],)', stat.true_part.text
          assert_equal '(block,[(expression,((,other,["taobao"]),)],)', stat.false_part.text
        end
      end
      
    end
  end
end
