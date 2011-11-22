require 'logger'

require_relative '../base_test'

require 'js/parser'

require_relative 'expr/expr'
require_relative 'stat/stat'


module XRayTest
  module JS
    class ParserTest < XRayTest::BaseTest 
      include XRay::JS

      include Expr::Expr
      include Stat::Stat

      
      def test_parse_program()
        js = '
          function say(name1, name2, name3) {
            alert(name + " hello world");
            console.debug(name2);
            name1 + name2 + name3;
          }
          ; // empty statement
          var a = 1;
          a++;
        ' 
        parser = create_parser(js)
        program = parser.parse_program
        elms = program.elements
        
        assert_equal 4, elms.length
      end 

      def test_parse_function_declaration
        js = '
          function sum(a1, a2, a3) {
            a1 = a2 + a3;
            a2 = a2 * a3;
            a3++;
          }
        ' 

        parser = create_parser(js)
        func = parser.parse_function_declaration

        assert_equal 'sum', func.name.text
        assert_equal '[a1,a2,a3]', func.parameters.text
      end

      def _test_with_fixture
        path = File.expand_path '../fixtures/js/jquery-1.7.js', File.dirname(__FILE__)
        body = IO.read(path)

        parser = create_parser(body)
        program = parser.parse_program
      end

      def create_parser(js)
        Parser.new(js, Logger.new(STDOUT))
      end

      def parse_js(action, js)
        parser = create_parser js
        parser.send(action)
      end

      def add_test(action, jses, exprs)
        if jses.class == String
          jses = [jses]
          exprs = [exprs]
        end
        jses.each_with_index do |js, index|
          expr = parse_js action, js 
          assert_equal exprs[index], expr.text
        end
      end
    end
  end
end
