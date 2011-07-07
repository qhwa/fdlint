require_relative 'helper'

require 'node'
require 'parser_visitable'


module XRayTest
  
  class ParserVisitableTest < Test::Unit::TestCase  
    
    Node = XRay::Node
    ParserVisitable = XRay::ParserVisitable

    class MockParser

      include ParserVisitable

      def parse_node
        puts 'parse node'

        parse_node_a
        parse_node_b

        Node.new 'node'
      end

      def parse_node_a
        puts 'parse node a'
        Node.new 'node a'
      end

      def parse_node_b
        puts 'parse node b'

        parse_node_c

        Node.new 'node b'
      end

      def parse_node_c
        puts 'parse node c'
        Node.new 'node c'
      end

    end

    class SimpleVisitor
      
      def visit_node(node)
        puts "visit node: #{node}"
        ['visit node', :info]
      end

      def visit_node_a(node)
        puts "visit node a: #{node}"
        ['visit node a', :warn]
      end

      def visit_node_b(node)
        puts "visit node b: #{node}"
        [
          ['visit node b 1', :warn],
          ['visit node b 2', :info]
        ]
      end

      def visit_node_c(node)
        puts "visit node c: #{node}"
        'visit node c'
      end
    end

    class SimpleObserver
      attr_reader :times

      def update(result, parser)
        puts "observer: #{result}"
        @times ||= 0
        @times += 1  
      end
    end


    def test
      parser = MockParser.new

      visitor = SimpleVisitor.new
      parser.add_visitor SimpleVisitor.new

      observer = SimpleObserver.new
      parser.add_observer observer

      parser.parse_node

      results = parser.results
      assert_equal 5, results.length
      assert_equal 5, observer.times
    end
    
  end

end
