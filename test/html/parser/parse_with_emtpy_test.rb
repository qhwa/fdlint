require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseWithEmptyTest < Test::Unit::TestCase
        ParseError = XRay::ParseError
        Element = XRay::HTML::Element
        
        def setup
          @parser = XRay::HTML::Parser.new('')
          @element = @parser.parse
        end

        def test_type_is_nil
          assert_equal @element, nil
        end

      end

    end
  end
end
