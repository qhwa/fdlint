require_relative '../node.rb'

module XRay
  module CSS
    Node = XRay::Node
    
    class StyleSheet < Node
      attr_reader :rulesets
      
      def initialize(rulesets)
        @rulesets = rulesets
      end

      def text
        rulessets.collect(&:text).join("\n")
      end

      def position
        rulesets.length ? rulesets[0].position : nil
      end
    end

    class RuleSet < Node
      attr_reader :selector, :declarations

      def initialize(selector, declarations)
        @selector, @declarations = selector, declarations
      end

      def text
        decs_text = declarations.collect { |dec|
          ' ' * 4 + dec.text
        }.join("\n")
        
        "#{selector} {\n #{decs_text} \n}"
      end

      def position
        selector.position
      end
    end

    class Declaration < Node
      attr_reader :property, :expression

      def initialize(property, expression)
        @property, @expression = property, expression
      end

      def text
        "#{property}: #{expression}"
      end

      def position
        property.position
      end
    end

  end
end
