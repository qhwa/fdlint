require 'fdlint/log_entry'

module Fdlint

  module Parser
  
    class VisitResult < LogEntry
    
      attr_reader :node

      def initialize(node, message, level)
        @node = node
        pos = node.position || Position.new(0, 0, 0)
        super message, level, pos.row, pos.column
      end
    end


    module ParserVisitable
      
      def self.included(klass)
        klass.public_instance_methods(true).grep(/^parse_/) do |method|
          wrap(klass, method)
        end

        def klass.method_added(method)
          unless @flag
            @flag = true
            case method.to_s
            when /^parse_/
              ParserVisitable.wrap(self, method)
            end
            @flag = false
          end
        end
      end

      def self.wrap(klass, method)
        method = method.to_s

        klass.instance_eval do

          old_method = "#{method}_without_visit"
          name       = method.sub /^parse_/, ''

          alias_method old_method, method

          define_method(method) do |*args, &block|
            before name
            node = self.send(old_method, *args, &block)
            node && visit(name, node)
            node
          end
        end
      end
   
      def parse_no_throw
        root = []
        begin
          root = self.parse
        rescue ParseError => e
          results << LogEntry.new(e.to_s, :fatal, e.position.row, e.position.column)
        end
        root
      end

      # Public: Add visitor hooks
      #
      # visitors - The visitors array. The members in the
      #            Array must be presented in this format:
      #            `[ scope, proc ]`
      #            where scope is the name of target node
      #            scope; proc is the handler.
      #
      # Returns Parser's visitors
      def add_visitors(visitors)
        if visitors === Array
          visitors.each do |target, visitor|
            add_visitor target, visitor
          end
        else
          visitors.public_methods(false).grep(/^visit_/).map do |method|
            add_visitor method.to_s.sub( /^visit_/, '' ), visitors.method( method )
          end
        end
        self.visitors
      end

      # Public: Add visitor hook
      #
      # target -  The target to watch. For example, when
      #           target is 'selector', then the visitor
      #           will be invoked after <code>parse_select
      #           </code> invoked by parser.
      # visitor - The handler proc. It will be yielded 
      #           with these arguments:
      #           * node:   current node scope, same as
      #                     `target` here
      #           * source: the entire file source
      #
      # Returns the visitors for the scope
      def add_visitor(scope, visitor)
        cache = visitors[scope.to_s] ||= []
        cache << visitor
      end

      def visitors
        @visitors ||= {}
      end

      def results
        @results ||= []
      end

      private 

        def visit(name, node)
          walk(name, node) do |result|
            results << result
          end
        end

        def before(name)
          walk 'before_parse_' << name, nil do |result|
            results << result
          end
        end

        def walk(name, node, &block)
          visitors = self.visitors[name.to_s]
          visitors && visitors.each do |visitor|
            result = visitor.call node, source, self
            yield result if result && block_given?
          end
        end

    end

  end
end
