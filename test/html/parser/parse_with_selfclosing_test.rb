require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseWithSelfClosingTagTest < Test::Unit::TestCase
        
        include XRay::HTML
        
        def test_self_close
          XRay::HTML::Parser.new('<div class="info" />') do |e|
            assert_equal Element.new('div', {:class=>"info"}), e
          end
        end

        def test_close_outside
          XRay::HTML::Parser.new('<div class="info" ></div>') do |e|
            assert_equal Element.new('div', {:class=>"info"}), e
          end
        end
        def test_center_tag
          XRay::HTML::Parser.new('<center></center>') do |e|
            assert_equal Element.new('center'), e
          end
        end

      end

    end
  end
end
