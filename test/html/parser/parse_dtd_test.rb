require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseDTDTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML
        
        def test_parse_html5_dtd
          parse('<!DOCTYPE html>') do |e|
            assert_equal Document.new(DTDElement.new('html')), e
          end
        end

        def test_parse_xhtml1
          src = %q(<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">)

          parse(src) do |e|
            assert_equal Document.new(DTDElement.new(%q(html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"))), e
          end
        end

        def test_parse_double_dtd
          parse('<!DOCTYPE html><!DOCTYPE html>') do |e|
            assert_equal e, [
              DTDElement.new('html'), 
              TextElement.new('<!DOCTYPE html>')
            ]
          end
        end

        def parse(src, &block)
          HtmlParser.parse(src, &block)
        end

      end

    end
  end
end
