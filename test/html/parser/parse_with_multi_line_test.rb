require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseWithMultiLineTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML
        
        def setup
          src = %q(<div 
          class="info"
          >information</div>)
          @parser = HtmlParser.new(src)
          @element = @parser.parse.children.first
        end

        def test_is_a_div_element
          assert @element.is_a?(Element)
          assert_equal @element.tag_name, 'div'
        end

        def test_have_one_child
          assert_equal [TextElement.new('information')], @element.children
        end

        def test_has_text
          assert_equal @element.inner_text, 'information'
        end

        def _test_has_html_text
          assert_equal @element.inner_html, 'information'
          assert_equal @element.outer_html, '<div class="info">information</div>'
        end

      end

    end
  end
end
