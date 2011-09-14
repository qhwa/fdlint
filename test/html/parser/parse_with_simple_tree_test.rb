require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseWithSimpleTreeTest < Test::Unit::TestCase
        ParseError = XRay::ParseError
        Element = XRay::HTML::Element
        TextElement = XRay::HTML::TextElement
        
        def setup
          @parser = XRay::HTML::Parser.new('<div><em>important</em> information!! Attention please!</div>')
          @element = @parser.parse
        end

        def test_type_is_element
          assert @element.is_a?(Element), 'must be an element'
        end

        def test_content_must_be_right
          assert_equal Element.new('div', nil, [
            Element.new('em', nil, [TextElement.new('important')]),
            TextElement.new(' information!! Attention please!')
          ]),@element, 'must contain two children'
        end

      end

    end
  end
end
