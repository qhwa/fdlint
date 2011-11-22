require_relative '../node'

module XRay
  module JS
    Node = XRay::Node

    class Element < Node
      attr_reader :type, :left, :right 

      def initialize(type, left, right = nil, position = nil)
        @type, @left, @right, @position = type, left, right, position
      end

      def text
        "(#{type},#{left},#{right})"
      end

      def position
        @position ? @position : 
            left ? left.position : 
            right ? right.position : nil
      end
    end

    class Elements < Node
      attr_reader :elements

      def initialize(elements, position = nil)
        @elements, @position = elements, position
      end

      def text
        "[#{elements.collect(&:text).join(',')}]"
      end

      def position
        @position ? @position : 
           elements.empty? ? nil : elements[0].position
      end

      def method_missing(m, *args, &block)
        @elements.send(m, *args, &block)
      end

    end

    class Program < Element
      alias :elements :left

      def initialize(elements)
        super('program', elements)
      end

    end

    class FunctionDeclaraion < Element
      attr_reader :body
      alias :name :left
      alias :parameters :right
       
      def initialize(name, parameters, body, pos)
        super('function', name, parameters, pos)
        @body = body
      end
    end

    class Statement < Element

      def end_with_semicolon=(end_with_semicolon)
        @end_with_semicolon = !!end_with_semicolon
      end

      def end_with_semicolon?
        @end_with_semicolon || false
      end

    end

    class VarStatement < Statement
      alias :declarations :left

      def initialize(declarations, position)
        super('var', declarations, nil, position)
      end
    end

    class EmptyStatement < Statement
      def initialize(pos)
        super(nil, pos)
      end
    end

    class ExpressionStatement < Statement
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def text
        "#{expression};" 
      end

      def position
        expression.position
      end
    end

    class Expression < Element
      def left_hand?
        @left_hand || false
      end

      def left_hand=(left_hand)
        @left_hand = left_hand
      end
    end

    class PrimaryExpression < Expression

      def initialize(type, expr, position = nil)
        super(type, expr, nil, position)
      end

      def text
        node.text
      end

      def node
        left
      end
    end

    class ConditionExpression < Expression
      attr_reader :condition
      
      def initialize(condition, left, right)
        super('?:', left, right, condition.position)
        @condition = condition
      end

      def text
        "(#{type},#{condition},#{left},#{right})"
      end

    end

  end
end
