module XRayTest
  module JS
    module Stat
      
      module Stat

        def test_parse_stat_block
          js = '
            {
              a = 1;
              b = 2;
              c++;
              i = i / 1;    
            }
          '

          parser = create_parser(js)

          block = parser.parse_stat_block
          assert_equal 4, block.statements.length
          assert_equal ['a = 1;', 'b = 2;', 'c++;', 'i = i / 1;'], 
              block.statements.collect(&:text)
        end
      end

    end
  end
end
