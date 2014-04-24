require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseWithAutoCloseTagTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML

        %w(area base basefont br col frame hr img input link meta param).each do |tag|
          define_method("test_#{tag}_tag") { check_tag tag }
          define_method("test_#{tag.upcase}_tag") { check_tag tag.upcase }
        end

        def test_manual_close
          src = %q(<div class="main"><input type="hidden" name="next_page" value="/dashboard/" ></input></div>)
          HtmlParser.parse(src) do |e|
            assert_equal Document.new(
              Element.new('div', {:class => 'main'}, [
                Element.new('input', [
                  Property.new(:type, 'hidden'), 
                  Property.new(:name, 'next_page'), 
                  Property.new(:value, '/dashboard/') 
                ])
              ])
            ), e
          end
        end

        def check_tag( name )
          assert_equal Document.new([
            Element.new( name, {:name => 'test'}),
            TextElement.new(' text' )
          ]), HtmlParser.parse("<#{name} name=\"test\"> text"),
          "TAG: #{name} will auto close and have no children"
        end
      
      end

    end
  end
end
