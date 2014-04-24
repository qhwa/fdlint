require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseWithEmptyTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML
        
        def setup
          @parser = HtmlParser.new('')
          @element = @parser.parse
        end

        def test_type_is_nil
          assert_equal @element, Document.new
        end

      end

    end
  end
end
