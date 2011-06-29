require 'strscan'
require 'logger'

require_relative '../helper'

require 'css/parser'

module XRayTest
  module CSS
    class ParserTest < Test::Unit::TestCase
      include XRay::CSS
      
      def test_parse_empty
        css = "  \n ";
        parser = create_parser(css)
        sheet = parser.parse_stylesheet

        assert_equal 0, sheet.rulesets.size, 'test empty css text'
      end
      
      # 解析样式表
      def test_parse_simple
          css = '
            body {
              color: #333;
              background: #ffffff url(img/bg.png) no-repeat left top; 
            }
            #content {
              font-size: 12px;
            }
            a:hover {
              color: #ff7300;
            }'
            
          parser = create_parser(css)
          sheet = parser.parse_stylesheet
          check_parse_simple(sheet)
      end
      
      def check_parse_simple(sheet)
        rulesets = sheet.rulesets
        assert_equal 3, rulesets.length
        
        # body
        rs = rulesets[0]
        assert_equal 'body', rs.selector
        
        decs = rs.declarations
        assert_equal 2, decs.length
        
        dec = decs[0];
        assert_equal 'color', dec.property
        assert_equal '#333', dec.expression
        
        dec = decs[1];
        assert_equal 'background', dec.property
        assert_equal '#ffffff url(img/bg.png) no-repeat left top', dec.expression
        
        # #content
        rs = rulesets[1]
        assert_equal '#content', rs.selector
        
        decs = rs.declarations
        assert_equal 1, decs.length
        
        dec = decs[0];
        assert_equal 'font-size', dec.property
        assert_equal '12px', dec.expression
        
        # a:hover
        rs = rulesets[2]
        assert_equal 'a:hover', rs.selector
      end
      
      def test_parse_with_doc_comment
        css = '
            body {
              color: #333;
              background: #ffffff url(img/bg.png) no-repeat left top; 
            }
            
            /**
             * div a.open
             */
            div a.open {
              font-size: 12px;
            }
            
            a:hover {
              color: #ff7300;
            }'
            
        parser = create_parser(css)
        sheet = parser.parse_stylesheet

        assert_equal 3, sheet.rulesets.length
        rs = sheet.rulesets[1]
        assert_equal 'div a.open', rs.selector
      end
      
      def test_parse_with_inline_comment
        css = '
            a {
              color: #333;
              text-decoration: none;
            },
            a: hover {
              color: #f7300; /* this is inline comment */
              text-decoration: underline;
            }
          '
        parser = create_parser(css)
        sheet = parser.parse_stylesheet
        
        assert_equal 2, sheet.rulesets.length
        
        rs = sheet.rulesets[1]
        dec = rs.declarations[0]
        
        assert_equal 'color', dec.property
        assert_equal '#f7300', dec.expression
      end
      
      def test_parse_expression_with_special
        css = %q[url("http://alibaba.com/{123}456")]
        parser = create_parser(css)
        
        expr = parser.parse_expression
        assert_equal css, expr
      end
      
      def test_parse_with_special
        css = %q[
            div ul>li:first {
              content: '{123}hello"';
              background: url("http://alibaba.com/{123}456")
            }]
            
        parser = create_parser(css)
        sheet = parser.parse_stylesheet
        
        rs = sheet.rulesets[0]
        assert_equal 'div ul>li:first', rs.selector
        
        decs = rs.declarations
        assert_equal 2, decs.length
        
        dec = decs[0]
        assert_equal 'content', dec.property
        assert_equal %q['{123}hello"'], dec.expression
        
        dec = decs[1]
        assert_equal 'background', dec.property
        assert_equal %q[url("http://alibaba.com/{123}456")], dec.expression
      end
      
      def create_parser(css)
        parser = Parser.new(css, Logger.new(STDOUT))
        return parser
      end
    
    end
  end
end
