require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseWithMultiChildrenTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML
        
        def setup
          @parser = HtmlParser.new('<em>important</em> information!! Attention please!')
          @element = @parser.parse
        end

        def test_content_must_be_right
          assert_equal Document.new([
            Element.new('em', nil, [TextElement.new('important')]),
            TextElement.new(' information!! Attention please!')
          ]),@element, 'must contain two children'
        end

      end

    end
  end
end
