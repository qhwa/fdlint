require 'logger'
require 'css/parser'
require_relative '../helper'


module XRayTest
  module CSS
    class ParserTest < Test::Unit::TestCase 
      ParseError = XRay::ParseError
      include XRay::CSS
      
      def test_parse_empty
        css = "  \n ";
        parser = create_parser css
        sheet = parser.parse_stylesheet

        assert_equal 0, sheet.rulesets.size, 'test empty css text'
      end
      
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
            
          parser = create_parser css
          sheet = parser.parse_stylesheet
          check_parse_simple sheet
      end
      
      def check_parse_simple(sheet)
        rulesets = sheet.rulesets
        assert_equal 3, rulesets.length
        
        # body
        rs = rulesets[0]
        assert_equal 'body', rs.selector.text
        
        decs = rs.declarations
        assert_equal 2, decs.length
        
        dec = decs[0];
        assert_equal 'color', dec.property.text
        assert_equal '#333', dec.expression.text
        
        dec = decs[1];
        assert_equal 'background', dec.property.text
        assert_equal '#ffffff url(img/bg.png) no-repeat left top', dec.expression.text
        
        # #content
        rs = rulesets[1]
        assert_equal '#content', rs.selector.text
        
        decs = rs.declarations
        assert_equal 1, decs.length
        
        dec = decs[0];
        assert_equal 'font-size', dec.property.text
        assert_equal '12px', dec.expression.text
        
        # a:hover
        rs = rulesets[2]
        assert_equal 'a:hover', rs.selector.text
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
            
        parser = create_parser css
        sheet = parser.parse_stylesheet

        assert_equal 3, sheet.rulesets.length
        rs = sheet.rulesets[1]
        assert_equal 'div a.open', rs.selector.text
      end
      
      def test_parse_with_inline_comment
        css = '
            a {
              color: #333;
              text-decoration: none;
            }
            a:hover {
              color: #f7300; /* this is inline comment */
              text-decoration: underline;
            }
          '
        parser = create_parser css
        sheet = parser.parse_stylesheet
        
        assert_equal 2, sheet.rulesets.length
        
        rs = sheet.rulesets[1]
        dec = rs.declarations[0]
        
        assert_equal 'color', dec.property.text
        assert_equal '#f7300', dec.expression.text
      end
      
      def test_parse_expression_with_special
        css = %q[url("http://alibaba.com/{123}456")]
        parser = create_parser css
        
        expr = parser.parse_expression
        assert_equal css, expr.text
      end
      
      def test_parse_with_special
        css = %q[
            div ul>li:first {
              content: '{123}hello"';
              background: url("http://alibaba.com/{123}456")
            }]
            
        parser = create_parser css
        sheet = parser.parse_stylesheet
        
        rs = sheet.rulesets[0]
        assert_equal 'div ul>li:first', rs.selector.text
        
        decs = rs.declarations
        assert_equal 2, decs.length
        
        dec = decs[0]
        assert_equal 'content', dec.property.text
        assert_equal %q['{123}hello"'], dec.expression.text
        
        dec = decs[1]
        assert_equal 'background', dec.property.text
        assert_equal %q[url("http://alibaba.com/{123}456")], dec.expression.text
      end

      def test_simple_selector
         css = %q[
            div, #header .mypart, .div ul li {
                font-size: 12px;
            }
            ul, body a, .part ul:first {
              background: #f00;
            }]

            
        parser = create_parser css
        sheet = parser.parse_stylesheet

        rs = sheet.rulesets[0];
        s_selectors = rs.selector.simple_selectors
        assert_equal 3, s_selectors.length
        
        assert_equal 'div', s_selectors[0].text
        assert_equal '#header .mypart', s_selectors[1].text
        assert_equal '.div ul li', s_selectors[2].text

        rs = sheet.rulesets[1]
        s_selectors = rs.selector.simple_selectors
        assert_equal 3, s_selectors.length

        assert_equal 'ul', s_selectors[0].text
        assert_equal 'body a', s_selectors[1].text
        assert_equal '.part ul:first', s_selectors[2].text
      end

      def test_bloken_css_01
        css = 'body {'
        parser = create_parser css

        assert_raise(ParseError) {
          parser.parse_stylesheet 
        }

        parser.reset

        begin
          parser.parse_stylesheet
        rescue ParseError => e
          puts "#{e.message}#{e.position}"
        end
      end

      def test_directive_with_expression
        css = %q[
            @import url(http://style.china.alibaba.com/css/fdevlib2/reset/reset-min.css);
            @import url(http://style.china.alibaba.com/css/fdevlib2/grid/grid-min.css);
            @import url("http://style.china.alibaba.com/css/lib/fdev-v3/fdev.css");
          ]

        parser = create_parser css
        sheet = parser.parse_stylesheet

        directives = sheet.directives
        assert_equal 3, directives.length

        directive = directives[0]
        assert_equal 'import', directive.keyword.text
        assert_equal 'url(http://style.china.alibaba.com/css/fdevlib2/reset/reset-min.css)', directive.expression.text

        directive = directives[2]
        assert_equal 'import', directive.keyword.text
        assert_equal 'url("http://style.china.alibaba.com/css/lib/fdev-v3/fdev.css")', directive.expression.text
      end

      def test_directive_with_expression_2
        css = %q[
            @import "subs.css";
            h1 { color: #ff0000 }
          ]

        parser = create_parser css
        sheet = parser.parse_stylesheet
        directives = sheet.directives

        assert_equal 1, directives.length
        directive = directives[0]
        assert_equal 'import', directive.keyword.text
        assert_equal '"subs.css"', directive.expression.text
      end

      def test_directive_with_block
        css = %q[
            @import "subs.css";
            @media print {
              @import "print-main.css";
              body { font-size: 10pt }
            }
            h1 { color: blue }
          ]

        parser = create_parser css
        sheet = parser.parse_stylesheet
        directives = sheet.directives
        assert_equal 2, directives.length

        rulesets = sheet.rulesets
        assert_equal 1, rulesets.length
      end

      def test_expression_with_more_semicolon
        css = %q[
            body {
              font-size: 12px;;
            }
            @import "subs.css";;
            @import print {
              body {
                font-size: 14px;
              }
            };
          ]

        parser = create_parser css
        sheet = parser.parse_stylesheet
        assert_equal 3, sheet.statements.length
      end

      def create_parser(css)
        Parser.new(css, Logger.new(STDOUT))
      end
      
    end
  end
end
