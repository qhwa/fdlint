require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseCommentTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML

        def test_simple_comment
          parse('<!--content-->') do |e|
            assert_equal CommentElement.new('content'), e
          end
        end

        def test_double_close
          parse('<!--content-->-->') do |e|
            assert_equal Document.new([CommentElement.new('content'), TextElement.new('-->')]), e
          end
        end

        def test_double_start_and_close
          parse(' <--<!--content-->-->') do |e|
            assert_equal Document.new([
              TextElement.new(' <--'),
              CommentElement.new('content'),
              TextElement.new('-->')
            ]), e
          end
        end

        def test_multiline
          parse("<!--content\nnewline-->") do |e|
            assert_equal CommentElement.new("content\nnewline"), e
          end
        end

        def parse(src, &block)
          Fdlint::Parser::HTML::HtmlParser.parse(src, &block)
        end

      end

    end
  end
end
