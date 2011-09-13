require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseWithTextTest < Test::Unit::TestCase
        ParseError = XRay::ParseError
        Element = XRay::HTML::Element
        TextElement = XRay::HTML::TextElement
        
        def setup
          @parser = XRay::HTML::Parser.new('information')
          @element = @parser.parse
        end

        def test_type_is_element
          assert @element.is_a?(TextElement)
        end

        def test_have_no_child
          assert_equal 0, @element.children.length
        end

        def test_has_text
          assert_equal 'information', @element.inner_text
          assert_equal 'information', @element.outer_text
        end

        def test_has_html_text
          assert_equal  'information', @element.inner_html
          assert_equal  'information', @element.outer_html
        end

      end

    end
  end
end
