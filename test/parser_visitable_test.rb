require_relative 'helper'

require 'fdlint/parser/node'
require 'fdlint/parser/parser_visitable'


module FdlintTest
  
  class ParserVisitableTest < Test::Unit::TestCase  
    
    Node            = Fdlint::Parser::Node
    ParserVisitable = Fdlint::Parser::ParserVisitable

    class MockParser

      include ParserVisitable

      def parse_node
        parse_node_a
        parse_node_b

        Node.new 'node'
      end

      def parse_node_a
        Node.new 'node a'
      end

      def parse_node_b

        parse_node_c

        Node.new 'node b'
      end

      def parse_node_c
        Node.new 'node c'
      end

      def source
      end
      
    end

    class SimpleVisitor
      
      def visit_node(node, source, parser)
        ['visit node', :info]
      end

      def visit_node_a(node, source, parser)
        ['visit node a', :warn]
      end

      def visit_node_b(node, source, parser)
        [
          ['visit node b 1', :warn],
          ['visit node b 2', :info]
        ]
      end

      def visit_node_c(node, source, parser)
        ['visit node c', :warn]
      end

    end

    def test_default
      parser = MockParser.new

      parser.add_visitors SimpleVisitor.new
      parser.parse_node

      results = parser.results
      assert_equal 4, results.length
    end
    
  end

end
