require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseWithAutoCloseTagTest < Test::Unit::TestCase

        include XRay::HTML

        %w(area base basefont br col frame hr img input link meta param).each do |tag|
          define_method("test_#{tag}_tag") do
            assert_equal [
              Element.new(tag, {:name => 'test'}),
              TextElement.new(' text' )
            ], XRay::HTML::Parser.parse("<#{tag} name=\"test\"> text"),
            "TAG: #{tag} will auto close and have no children"
          end
        end

        def test_manual_close
          src = %q(<div class="main"><input type="hidden" name="next_page" value="/dashboard/" ></input></div>)
          XRay::HTML::Parser.parse(src) do |e|
            assert_equal Element.new('div', {:class => 'main'}, [
              Element.new('input', {:type=>'hidden', :name=>'next_page', :value=>'/dashboard/'})
            ]), e
          end
        end

        
      end

    end
  end
end
