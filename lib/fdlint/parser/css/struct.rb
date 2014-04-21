module Fdlint; module Parser
  module CSS

    Node = ::Fdlint::Parser::Node
    
    class StyleSheet < Node
      attr_reader :statements

      def initialize(statements)
        @statements = statements
      end

      def text
        rulesets.collect(&:text).join("\n")
      end

      def position
        rulesets.empty? ? nil : rulesets[0].position
      end

      def directives
        statements.select { |elm| elm.is_a? Directive }
      end

      def rulesets
        statements.select { |elm| elm.is_a? RuleSet }
      end

      alias :at_rules :directives
    end

    class Directive < Node
      attr_reader :keyword, :expression, :block

      def initialize(keyword, expression, block = nil)
        @keyword, @expression, @block = keyword, expression, block 
      end

      def text
        t = "@#{keyword}"
        if expression
          t += "#{expression}"
        end
        if block
          t += "{\n#{block}\n}\n"
        else
          t += ';'
        end
        t
      end

      def position
        keyword.position
      end
    end

    class RuleSet < Node
      attr_reader :selector, :declarations

      def initialize(selector, declarations)
        @selector, @declarations = selector, declarations
      end

      def text
        decs_text = declarations.collect { |dec|
          "#{' ' * 4}#{dec};"
        }.join("\n")
        
        "#{selector} {\n#{decs_text}\n}"
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
        simple_selectors.empty? ? nil : simple_selectors[0].position
      end
    end

    class Declaration < Node
      attr_reader :property, :value

      def initialize(property, value)
        @property, @value = property, value
      end

      def text
        "#{property}: #{value}"
      end

      def position
        property.position
      end
    end

  end

end; end
