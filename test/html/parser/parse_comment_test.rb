require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseCommentTest < Test::Unit::TestCase

        include XRay::HTML
        
        def test_simple_comment
          parse('<!--content-->') do |e|
            assert_equal CommentElement.new('content'), e
          end
        end

        def test_double_close
          parse('<!--content-->-->') do |e|
            assert_equal [CommentElement.new('content'), TextElement.new('-->')], e
          end
        end

        def test_double_start_and_close
          parse(' <--<!--content-->-->') do |e|
            assert_equal [
              TextElement.new(' <--'),
              CommentElement.new('content'),
              TextElement.new('-->')
            ], e
          end
        end

        def test_multiline
          parse("<!--content\nnewline-->") do |e|
            assert_equal CommentElement.new("content\nnewline"), e
          end
        end

        def parse(src, &block)
          XRay::HTML::Parser.parse(src, &block)
        end

      end

    end
  end
end
