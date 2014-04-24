require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseWithSimpleTreeTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML

        def test_simple_tree
          parse('<div><em>important</em> information!! Attention please!</div>') do |element|
            assert_equal Element.new('div', nil, [
              Element.new('em', nil, [TextElement.new('important')]),
              TextElement.new(' information!! Attention please!')
            ]), element.children.first, 'must contain two children'
          end
        end

        def test_more_deeper
          parse('<div class="info"><span style="color:red"><em>important</em> information!! Attention please!</span></div>') do |element|
            assert_equal Element.new('div', {:class => 'info'}, [
              Element.new('span', {:style => 'color:red'}, [
                Element.new('em', nil, [TextElement.new('important')]),
                TextElement.new(' information!! Attention please!')
              ])
            ]), element.children.first, 'must contain two children'
          end
        end

        protected
        def parse(src, &block)
          HtmlParser.parse(src, &block)
        end

      end

    end
  end
end
