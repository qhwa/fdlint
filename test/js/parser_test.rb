# encoding: utf-8
require File.expand_path('../helper', File.dirname(__FILE__))

require 'js/parser'

require_relative 'expr/expr'
require_relative 'stat/stat'


module XRayTest
  module JS
    class ParserTest < Test::Unit::TestCase 
      include XRay::JS

      include Expr::Expr
      include Stat::Stat

      
      def test_parse_program()
        js = '
          /**
           * this is mutiline comment
           */
          function say(name1, name2/*inline comment*/, name3) {
            alert(name + " hello world");
            console.debug(name2);
            name1 + name2 + // line comment
              name3;
          }
          ; // hello this is comment
          var a = 1;
          a++;
        ' 
        parser = create_parser(js)
        program = parser.parse_program
        elms = program.elements
        
        assert_equal 4, elms.length

        s_comments = parser.singleline_comments
        assert_equal 2, s_comments.length

        m_comments = parser.mutiline_comments
        assert_equal 2, m_comments.length
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

      def test_parse_singleline_comment
        js = '
          // this is simple comment
          a = 123;
        ' 
        
        comment = parse_js :parse_singleline_comment, js 
        assert_equal '// this is simple comment', comment.text
      end


      def create_parser(js)
        Parser.new js, XRayTest::Logger.new
        
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


