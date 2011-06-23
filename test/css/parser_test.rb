require 'strscan'
require 'logger'

require_relative '../helper'

require 'css/parser'

module XRayTest
  module CSS
    class ParserTest < Test::Unit::TestCase
      include XRay::CSS
      
      def test_stylesheet_empty
        css = "  \n ";
        parser = create_parser(css)
        sheet = parser.parse_stylesheet

        assert_equal 0, sheet.rulesets.size, 'test empty css text'
      end
      
      # 解析样式表
      def test_parse_stylesheet_simple
          css = '
            body {
              color: #333;
              background: #ffffff url(img/bg.png) no-repeat left top; 
            }
            #content {
              # font-size: 12px;
            }
            a:hover {
              # color: #ff7300;
            }'
            
          parser = create_parser(css)
          sheet = parser.parse_stylesheet
          check_stylesheet_simple(sheet)
      end
      
      def check_stylesheet_simple(sheet)
        rulesets = sheet.rulesets
        assert_equal 3, rulesets.length
        
        # body
        rs = rulesets[0]
        assert_equal 'body', rs.selector
        
        decs = rs.declarations
        ssert_equal 2, decs.length
        
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
        assert_equal '#ff7300', dec.expression
        
        # a:hover
        rs = rulesets[2]
        assert_equal 'a:hover', rs.selector
      end
      
      def create_parser(css)
        parser = Parser.new(css)
        parser.log = Logger.new(STDOUT)
        return parser
      end
    
    end
  end
end