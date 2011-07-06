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
        rulesets.collect(&:text).join("\n")
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

    class Selector < Node
      attr_reader :simple_selectors

      def initialize(simple_selectors)
        @simple_selectors = simple_selectors
      end

      def text
        @simple_selectors.collect(&:text).join(', ')
      end

      def position
        simple_selectors.length ? simple_selectors[0] : nil
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
