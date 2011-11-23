module XRayTest
  module JS
    module Stat
      
      module Try
        def test_stat_try
          js = '
            try {
              a = 1 + 2;
            } catch (e) {
              console.debug("something error");    
            } finally {
              hello();    
            }
          '

          stat = parse_js :parse_stat_try, js
          
          assert_equal 'try', stat.type
          assert_equal '(block,[(expression,(=,a,(+,1,2)),)],)', stat.try_part.text

          assert_equal 'catch', stat.catch_part.type
          assert_equal 'e', stat.catch_part.left.text
          assert_equal '(block,[(expression,((,(.,console,debug),["something error"]),)],)', stat.catch_part.right.text

          assert_equal '(block,[(expression,((,hello,[]),)],)', stat.finally_part.text
        end
      end

    end
  end
end
