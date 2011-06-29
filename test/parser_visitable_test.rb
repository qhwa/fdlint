require_relative 'helper'

require 'node'
require 'parser_visitable'


module XRayTest
  
  class ParserVisitableTest < Test::Unit::TestCase  
    
    Node = XRay::Node
    ParserVisitable = XRay::ParserVisitable

    class MockParser

      include ParserVisitable

      def parse_mock1
        puts 'parse_mock1'
        Node.new('mock node1') 
      end

      def parse_mock2
        puts 'parse_mock2'
        Node.new('mock node2')
      end

    end

    class SimpleVisitor
      
      def visit_mock1(node)
        puts "in visit_mock1: #{node}"
        ['visit_mock1', :info]
      end

      def visit_mock2(node)
        puts "in visit_mock2: #{node}"
        ['visit_mock2', :warn]
      end

    end

    class SimpleObserver
      attr_reader :times

      def update(result, parser)
        puts "Observer: result"
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

      parser.parse_mock1
      parser.parse_mock2
      
      parser.parse_mock1_without_visit
      parser.parse_mock2_without_visit

      results = parser.parse_results
      assert_equal 2, results.length
      puts results[0], results[1]

      assert_equal 2, observer.times
    end
    
  end

end
