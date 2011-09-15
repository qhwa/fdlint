require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseWithTextTest < Test::Unit::TestCase

        include XRay::HTML
        
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
        end

        def test_has_html_text
          assert_equal  'information', @element.inner_html
          assert_equal  'information', @element.outer_html
        end

        def test_with_lt_mark
          assert_equal TextElement.new('1 < 3 > 2'), XRay::HTML::Parser.parse('1 < 3 > 2')
        end

        def test_with_and_mark
          assert_equal TextElement.new('1 &lt; 3 &gt; 2'), XRay::HTML::Parser.parse('1 &lt; 3 &gt; 2')
        end

      end

    end
  end
end
