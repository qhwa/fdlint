# encoding: utf-8

require_relative '../helper'

require 'css/parser'


module XRayTest
  module CSS
    class ParserTest < Test::Unit::TestCase 
      ParseError = XRay::ParseError
      include XRay::CSS

      def test_parse_stylesheet_empty
        css = "  \n "
        sheet = parse_css css
        assert_equal 0, sheet.statements.size
      end

      def test_parse_directive
        css = '
          @import "subs.css";
          @import "print-main.css" print;
          @-moz-border-radius print {
            body { font-size: 10pt }
          }
          h1 { color: blue } 

          @import url(http://style.china.alibaba.com/css/fdevlib2/grid/grid-min.css);
        '
        sheet = parse_css css
        
        at_rules = sheet.at_rules 
        assert_equal 4, at_rules.size
       
        assert_equal 'import', at_rules[1].keyword.text
        assert_equal '"print-main.css" print', at_rules[1].expression.text
        assert_equal '-moz-border-radius', at_rules[2].keyword.text 
        assert_equal 'url(http://style.china.alibaba.com/css/fdevlib2/grid/grid-min.css)', 
            at_rules[3].expression.text 
      end

      def test_parse_ruleset
        css = '
          a { font-size: 12px }
          { color: #fff } /* no selector */
        '

        sheet = parse_css css
        rs = sheet.rulesets
        assert_equal 2, rs.size

        assert_equal 'a', rs[0].selector.text
        assert_equal nil, rs[1].selector
      end

      def test_parse_selector
        css = '
          div, #header .mypart, .div ul li {
              font-size: 12px;
          }
          ul, body a, .part ul:first {
            background: #f00;
          }

          a[name="helloworld"], a {
            color: #fff;
          }
        '

        sheet = parse_css css
        rs = sheet.rulesets
        assert_equal 3, rs.length

        assert_equal 'div, #header .mypart, .div ul li', rs[0].selector.text
        assert_equal 3, rs[0].selector.simple_selectors.length

        assert_equal 'ul, body a, .part ul:first', rs[1].selector.text
        
        assert_equal 'a[name="helloworld"]', rs[2].selector.simple_selectors[0].text
      end

      def test_parse_declarations
        css = '
          body {
            ;;
            color: #333;
            ; 
            font-size: 12px   
          }

          a:hover {
            color: #ff7300    
          }

          #content {
            font-size: 12px;
            width: 952px;
            background: #ffffff url(img/bg.png) no-repeat left top;
          }
        '

        sheet = parse_css css
        rs = sheet.rulesets
        assert_equal 3, rs.size

        decs = rs[0].declarations
        assert_equal 2, decs.size
        assert_equal 'color', decs[0].property.text
        assert_equal '#333', decs[0].value.text
        assert_equal 'font-size', decs[1].property.text
        assert_equal '12px', decs[1].value.text

        assert_equal 1, rs[1].declarations.size
        
        decs = rs[2].declarations
        assert_equal 3, decs.size
        assert_equal 'font-size', decs[0].property.text
        assert_equal '12px', decs[0].value.text
        assert_equal 'width', decs[1].property.text
        assert_equal '952px', decs[1].value.text
        assert_equal '#ffffff url(img/bg.png) no-repeat left top', decs[2].value.text
      end

      def test_parse_property
        css = %q[
          body {
            color: #f00;
            _color: #0ff;
            *font-size: 12px;
            background: '';
            -moz-border-radius: ''
          }
        ]

        sheet = parse_css css
        decs = sheet.rulesets[0].declarations
        assert_equal 'color', decs[0].property.text
        assert_equal '_color', decs[1].property.text
        assert_equal '*font-size', decs[2].property.text
        assert_equal 'background', decs[3].property.text
        assert_equal '-moz-border-radius', decs[4].property.text
      end

      def test_parse_value
        css = %q[  
          div ul>li:first {
            content: '{123}hello"';
            background: url("http://alibaba.com/{123}456");       
            font-family: "Lucida Sans", Arial, "\6587\6CC9\9A7F\5FAE\7C73\9ED1";
            font-size: ' ';
            content: ''
          }
        ]

        sheet = parse_css css
        rs = sheet.rulesets[0]
        decs = rs.declarations

        assert_equal 'div ul>li:first', rs.selector.text
        assert_equal %q/'{123}hello"'/, decs[0].value.text
        assert_equal 'url("http://alibaba.com/{123}456")', decs[1].value.text
        assert_equal '"Lucida Sans", Arial, "\6587\6CC9\9A7F\5FAE\7C73\9ED1"', 
            decs[2].value.text
        assert_equal "' '", decs[3].value.text
        assert_equal "''", decs[4].value.text
      end
      
      def test_parse_stylesheet_broken_01
        css = 'body {'

        assert_raise(ParseError) {
          parse_css css
        }

        begin
          parse_css css
        rescue ParseError => e
          pos = e.position
          assert_equal 1, pos.row
          assert_equal 7, pos.column
        end
      end

      def test_parse_comment
        css = '
          /**
           * this is comment
           */
          body {
            font-size: 12px;
            /**/
            /**这个是中文注释*/ 
          }
          /*this is comment 2*/
          
          a { font-size: 14px; }
        '

        parser = create_parser css
        parser.parse_stylesheet

        comments = parser.comments
        assert_equal 4, comments.size
        assert_equal '/**这个是中文注释*/', comments[2].text
      end

      def test_parse_stylesheet_css3
        css = <<END
@charset: "utf-8";

/** animation **/
@-webkit-keyframes greenPulse {
    from { background-color: #749a02; -webkit-box-shadow: 0 0 9px #333; }
    50% { background-color: #91bd09; -webkit-box-shadow: 0 0 18px #91bd09; }
    to { background-color: #749a02; -webkit-box-shadow: 0 0 9px #333; }
}

.green.button {
    -webkit-animation-name: greenPulse;
    -webkit-animation-duration: 2s;
    -webkit-animation-iteration-count: infinite;
}

/** media query import **/
@import url(color.css) screen and (color);

/** media query **/
@media all and (min-width:500px) {
    .big {
      font-size:120%;
    }
}

@media screen and (color), projection and (color) {
    .big {
        font-size:120%;
    }
}
END
        sheet = parse_css css
        assert_equal 6, sheet.statements.size
        rule = sheet.at_rules[1]
        
        assert_equal '-webkit-keyframes', rule.keyword.text
        rs = rule.block.rulesets
        assert_equal 3, rs.size

        assert_equal '50%', rs[1].selector.text
        assert_equal '-webkit-box-shadow', rs[1].declarations[1].property.text
        assert_equal '0 0 18px #91bd09', rs[1].declarations[1].value.text

        rule = sheet.at_rules.last
        assert_equal 'screen and (color), projection and (color)', rule.expression.text
        
        rs = rule.block.rulesets[0]
        assert_equal '.big', rs.selector.text 
        assert_equal 'font-size: 120%', rs.declarations[0].text
      end

      private

      def create_parser(css)
        Parser.new css, XRayTest::Logger.new
      end

      def parse_css(css, name = 'stylesheet')
        parser = create_parser css
        parser.send "parse_#{name}"
      end



    end
  end
end
