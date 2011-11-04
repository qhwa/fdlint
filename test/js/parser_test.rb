require 'logger'

require_relative '../base_test'

require 'js/parser'

require_relative 'stat/simple'

module XRayTest
  module JS
    class ParserTest < XRayTest::BaseTest 
      include XRay::JS

      include Stat::Simple

      
      def test_parse_program()
        js = '
          function say(name1, name2, name3) {
            alert(name + " hello world");
            console.debug(name2);
            name1 + name2 + name3;
          }

          var a = 1;
          a++;
        ' 
        parser = create_parser(js)
        program = parser.parse_program

        assert_equal 3, program.elements.length

        func = program.elements[0]
        assert_equal 3, func.body.elements.length
      end 

      def test_parse_function_declaration
        js = '
          function sum(a1, a2, a3) {
            a1 = a2 + a3;
            a2 = a2 * a3;
            a3++;
            return a1 + a2 + a3;
          }
        ' 

        parser = create_parser(js)
        func = parser.parse_function_declaration

        assert_equal 'sum', func.name.text

        params = func.parameters
        assert_equal 3, params.length
        assert_equal %w(a1 a2 a3), params.collect(&:text) 

        elms = func.body.elements
        assert_equal 4, elms.length
        assert_equal 'a2 = a2 * a3', elms[1].value
      end

      def create_parser(js)
        Parser.new(js, Logger.new(STDOUT))
      end
    end
  end
end
