module XRayTest
  module JS
    module Stat
      
      module Simple
        def test_parse_stat_simple
          js = 'a = 1; i = 2; a++;' 
          parser = create_parser(js)
          
          stat = parser.parse_statement
          assert_equal 'a = 1', stat.value

          stat = parser.parse_statement
          assert_equal 'i = 2', stat.value

          stat = parser.parse_statement
          assert_equal 'a++', stat.value
        end

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
          assert_equal ['a = 1', 'b = 2', 'c++', 'i = i / 1'], 
              block.statements.collect(&:value)
        end
      end

    end
  end
end
