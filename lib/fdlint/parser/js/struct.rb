require_relative '../node'

module Fdlint

  module Parser

    module JS

      Node = ::Fdlint::Parser::Node

      class Element < Node
        attr_reader :type, :left, :right

        def initialize(type, left = nil, right = nil, position = nil)
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

        def contains?(target)
          return true if target == @type
          left && left.respond_to?(:contains?) && left.contains?(target) or 
            right && right.respond_to?(:contains?) && right.contains?(target)
        end

      end

      class Elements < Node
        attr_reader :elements, :type

        def initialize(elements, position = nil)
          @elements, @position = elements, position
          @type = 'elements'
        end

        def text
          "[#{elements.collect(&:text).join(',')}]"
        end

        def position
          @position ? @position : 
             elements.empty? ? nil : elements[0].position
        end

        def method_missing(m, *args, &block)
          @elements.send m, *args, &block
        end

        def contains?( target )
          @elements.any? {|elm| elm.contains? target }
        end

        alias :contain? :contains?
      end

      # The whole program element
      # Javascript files are first parsed into programs.
      class Program < Element
        alias :elements :left

        def initialize(elements)
          super 'program', elements
        end

      end

      # Function declaraion
      # key word 'function' parsed as FunctionDeclaraion
      class FunctionDeclaraion < Element
        attr_reader :body
        alias :name :left
        alias :parameters :right
         
        def initialize(name, parameters, body, pos)
          super 'function', name, parameters, pos
          @body = body
        end
      end

      class Statement < Element

        def end_with_semicolon=(end_with_semicolon)
          @end_with_semicolon = !!end_with_semicolon
        end

        def end_with_semicolon?
          !!@end_with_semicolon
        end

      end

      class VarStatement < Statement
        alias :declarations :left

        def initialize(declarations, position)
          super 'var', declarations, nil, position
        end
      end

      class BlockStatement < Statement
        alias :elements :left

        def initialize(elements, pos)
          super 'block', elements, nil, pos
        end
      end

      class IfStatement < Statement
        attr_reader :false_part
        alias :condition :left
        alias :true_part :right
         
        def initialize(condition, true_part, false_part, position)
          super 'if', condition, true_part, position
          @false_part = false_part
        end
      end

      class SwitchStatement < Statement
        alias :expression :left
        alias :case_block :right
         
        def initialize(expression, case_block, position)
          super 'switch', expression, case_block, position
        end
      end

      class CaseBlockStatement < Statement
        attr_reader :bottom_case_clauses
        alias :case_clauses :left
        alias :default_clause :right

        def initialize(case_clauses, default_clause, bottom_case_clauses, position)
          super 'caseblock', case_clauses, default_clause, position
          @bottom_case_clauses = bottom_case_clauses
        end
      end

      class DowhileStatement < Statement
        alias :body :left
        alias :condition :right

        def initialize(body, condition, pos)
          super 'dowhile', body, condition, pos
        end
      end

      class WhileStatement < Statement
        alias :condition :left
        alias :body :right

        def initialize(condition, body, pos)
          super 'while', condition, body, pos
        end
      end

      class ForStatement < Statement
        alias :condition :left
        alias :body :right

        def initialize(condition, body, pos)
          super 'for', condition, body, pos
        end
      end

      class ForConditionElement < Element
        attr_reader :third
        alias :first :left
        alias :second :right

        def initialize(type, first, second, third, pos)
          super type, first, second
          @third = third
        end

      end

      class TryStatement < Statement
        attr_reader :finally_part
        alias :try_part :left
        alias :catch_part :right

        def initialize(try_part, catch_part, finally_part, pos)
          super 'try', try_part, catch_part, pos
          @finally_part = finally_part
        end
      end

      class ExpressionStatement < Statement
        alias :expression :left

        def initialize(expression)
          super 'expression', expression
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
          super type, expr, nil, position
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
          super '?:', left, right, condition.position
          @condition = condition
        end

        def text
          "(#{type},#{condition},#{left},#{right})"
        end

      end

      class FunctionExpression < Expression
        attr_reader :body
        alias :name :left
        alias :parameters :right
         
        def initialize(func)
          super 'function', func.name, func.parameters, func.position
          @body = func.body
        end
      end

    end
  end
end
