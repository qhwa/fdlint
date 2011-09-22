require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseDTDTest < Test::Unit::TestCase
        
        include XRay::HTML
        
        def test_parse_html5_dtd
          parse('<!DOCTYPE html>') do |e|
            assert_equal DTDElement.new('html'), e
          end
        end

        def test_parse_xhtml1
          src = %q(<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">)

          parse(src) do |e|
            assert_equal DTDElement.new(%q(html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd")), e
          end
        end

        def test_parse_double_dtd
          parse('<!DOCTYPE html><!DOCTYPE html>') do |e|
            assert_equal [
              DTDElement.new('html'), 
              TextElement.new('<!DOCTYPE html>')
            ], e
          end
        end

        def parse(src, &block)
          XRay::HTML::Parser.parse(src, &block)
        end

      end

    end
  end
end
