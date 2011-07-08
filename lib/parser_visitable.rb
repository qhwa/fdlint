require 'observer'

require_relative 'log_entry'
require_relative 'base_parser'

module XRay
  
  class VisitResult < LogEntry
  
    attr :message, :level, :node

    def initialize(node, message, level)
      @node, @message, @level = node, message, level
      update_pos( node )
    end

    def update_pos( node )
      if node
        self.column = node.position.column
        self.row = node.position.row
      end
    end

    def node=(n)
      update_pos n
      @node = n
    end

    def to_s
      "[#{level.to_s.upcase}] #{node.nil? ? '' : node.position} #{message}"
    end

  end


  module ParserVisitable
    
    include Observable

    attr_reader :results

    def self.included(klass)
      klass.public_instance_methods(false).each do |method|
        wrap(klass, method)
      end

      def klass.method_added(method)
        unless @flag
          @flag = true
          ParserVisitable.wrap(self, method)
          @flag = false
        end
      end
    end

    def self.wrap(klass, method)
      method = method.to_s
      unless method.index 'parse_'
        return
      end

      klass.instance_eval do
        old_method = "#{method}_without_visit"
        alias_method old_method, method

        define_method(method) do |*args, &block|
          node = self.send(old_method, *args, &block)
          node && visit(method, node)
          node
        end
      end
    end

    def initialize
      @visitors = []
      @results = []
    end

    def add_visitor(visitor)
      @visitors << visitor
    end

    private 

    def visit(name, node)
      name = name.sub(/^parse_/, '')
      @visitors.each { |visitor|
        method = 'visit_' + name
        if visitor.respond_to? method
          results = visitor.send(method, node)
          results && notify(node, results)
        end
      }
    end

    def notify(node, results)
      if results.empty?
        return
      end

      results = [results] unless results[0].class == Array
      results.each { |ret|
        message, level = ret
        result = VisitResult.new(node, message, level || :info)
        @results << result
        self.changed
        notify_observers(result, self)
      }
    end

  end

  class BaseParser
    include ParserVisitable
  end


end
