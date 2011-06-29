require 'observer'

module XRay
  
  VisitResult = Struct.new(:node, :message, :level)
  class VisitResult
    def to_s
      "[#{level.to_s.upcase}] #{node.position} #{message}"
    end
  end


  module ParserVisitable
    
    include Observable

    attr_reader :parse_results

    def self.included(klass)
      klass.instance_methods(false).each do |method|
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
      unless method.index('parse_')
        return
      end

      klass.instance_eval do
        old_method = "#{method}_without_visit"
        alias_method old_method, method

        define_method(method) do |*args, &block|
          node = self.send(old_method, *args, &block)
          visit(method, node)
          node
        end
      end
    end

    def initialize
      @visitors = []
      @parse_results = []
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
          message, level = visitor.send(method, node)
          if message
            result = VisitResult.new(node, message, level || :info)
            @parse_results << result
            self.changed
            notify_observers(result, self)
          end
        end
      }
    end

  end
end
