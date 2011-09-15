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
            ], XRay::HTML::Parser.parse("<#{tag} name='test'> text"),
            "TAG: #{tag} will auto close and have no children"
          end
        end
        
      end

    end
  end
end
