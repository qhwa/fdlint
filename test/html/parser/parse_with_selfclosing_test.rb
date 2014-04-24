require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseWithSelfClosingTagTest < Test::Unit::TestCase
        
        include Fdlint::Parser::HTML

        def test_self_close
          HtmlParser.parse('<div class="info" />') do |e|
            assert_equal Element.new('div', {:class=>"info"}), e.children.first
          end
        end

        def test_br_tag_closed_without_space
          HtmlParser.parse('<br/>') do |e|
            assert_equal Element.new('br'), e.children.first
          end
        end

        def test_close_outside
          HtmlParser.parse('<div class="info" ></div>') do |e|
            assert_equal Element.new('div', {:class=>"info"}), e.children.first
          end
        end

        def test_center_tag
          HtmlParser.parse('<center></center>') do |e|
            assert_equal Element.new('center'), e.children.first
          end
        end

      end

    end
  end
end
