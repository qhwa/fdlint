require 'observer'

require_relative 'log_entry'

module XRay
  
  class VisitResult < LogEntry
  
    attr_reader :node

    def initialize(node, message, level)
      @node = node
      pos = node.position || Position.new(0, 0, 0)
      super message, level, pos.row, pos.column
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
        name = method.sub /^parse_/, ''
        alias_method old_method, method

        define_method(method) do |*args, &block|
          before name, *args
          node = self.send(old_method, *args, &block)
          node && visit(name, node)
          node
        end
      end
    end
 
    def parse_no_throw
      begin
        self.parse
      rescue ParseError => e
        @results ||= []
        @results << LogEntry.new(e.to_s, :fatal, e.position.row, e.position.column)
      end
    end

    def add_visitor(visitor)
      @visitors ||= {}
      
      visitor.class.public_instance_methods(true).each do |method|
        method = method.to_s
        if method.index('visit_') == 0 || 
            method.index('before_parse_') == 0
          cache = @visitors[method] ||= []
          cache << visitor
        end 
      end
    end

    def add_visitors(visitors)
      visitors.each { |visitor| add_visitor visitor }
    end

    def results
      @results || []
    end

    private 

    def visit(name, node)
      walk(name, 'visit_', node) do |result|
        result && notify(node, result)
      end
    end

    def before(name, *args)
      walk name, 'before_parse_', *args
    end

    def walk(name, prefix, *args, &block)
      unless @visitors
        return
      end

      method = prefix + name 
      visitors = @visitors[method]
      visitors && visitors.each do |visitor|
        result = visitor.send method, *args
        block && block.call(result)
      end
    end

    def notify(node, results)
      @results ||= []
      if results.is_a?(Array) && results.size > 0
        if results[0].is_a? Array
          results.each do |ret|
            do_notify node, ret, ret.is_a?(VisitResult)
          end
        else
          do_notify node, results
        end
      elsif results.is_a? VisitResult
        do_notify node, results, true 
      end
    end

    def do_notify(node, ret, flag = false)
      ret = VisitResult.new(node, ret[0], ret[1]) unless flag
      @results << ret
      self.changed
      notify_observers ret, self
    end

  end

end
