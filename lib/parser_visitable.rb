require 'observer'

require_relative 'log_entry'

module XRay
  
  class VisitResult < LogEntry
  
    attr_reader :node

    def initialize(node, message, level)
      @node = node
      pos = node.position || Position.new(0, 0, 0)
      super(message, level, pos.row, pos.column)
    end
  end


  module ParserVisitable
    
    include Observable

    def self.included(klass)
      klass.public_instance_methods(true).each do |method|
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

    def add_visitor(visitor)
      @visitors ||= []
      @visitors << visitor
    end

    def results
      @results || []
    end

    private 

    def visit(name, node)
      unless @visitors
        return
      end

      name = name.sub(/^parse_/, '')
      @visitors.each do |visitor|
        method = 'visit_' + name
        if visitor.respond_to? method
          results = visitor.send(method, node)
          results && notify(node, results)
        end
      end
    end

    def notify(node, results)
      if results.empty?
        return
      end

      results = [results] unless results[0].class == Array
      results.each { |ret|
        message, level = ret
        result = VisitResult.new(node, message, level || :info)
        @results ||= []
        @results << result
        self.changed
        notify_observers(result, self)
      }
    end

  end

end
