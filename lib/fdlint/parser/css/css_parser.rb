require_relative 'struct'

module Fdlint; module Parser

  module CSS
    
    class CssParser < ::Fdlint::Parser::BaseParser

      include ::Fdlint::Parser::ParserVisitable

      TERM       = %q([^;{}'"])
      TERM2      = %q([^;{}'",])
      QUOT_EXPR  = "'[^']*'"
      DQUOT_EXPR = '"[^"]*"'
      R_IDENT    = /-?[_a-z][_a-z0-9-]*/
      R_ANY      = %r"((?:#{TERM})|(?:#{QUOT_EXPR})|(?:#{DQUOT_EXPR}))+"
      R_SELECTOR = %r"((?:#{TERM2})|(?:#{QUOT_EXPR})|(?:#{DQUOT_EXPR}))+"
      R_PROPERTY = /[*_+\\]?-?[_a-z\\][\\_a-z0-9-]*/
      
      attr_reader :comments

      def initialize(css)
        super
        @comments = []
      end

      def parse_stylesheet(inner = false)
        debug { 'parse stylesheet' }
        
        do_parse_comment

        stats = batch(:parse_statement) do 
          skip_empty
          !(inner ? check(/\}/) : eos?)
        end
        
        StyleSheet.new stats
      end

      alias_method :parse, :parse_stylesheet

      # ruleset or directive
      def parse_statement
        debug { 'parse statement' }

        if check /@font-face/
          parse_font_definition
        elsif check /@/
          parse_directive
        else
          parse_ruleset
        end
      end

      def parse_font_definition
        debug { 'parse font definition' }
        skip /@font-face/
        skip /\{/
          declarations = parse_declarations
        skip /\}/

        FontDef.new(declarations)
      end

      def parse_directive
        debug { 'parse directive' }

        skip /@/
        keyword = scan R_IDENT 
        skip_empty
        
        expr = check(/\{/) || check(/;/) ? nil : 
            scan(R_ANY)

        block = nil
        if check /\{/
          skip /\{/
          block = parse_stylesheet true
          skip /\}/
        end

        unless block
          skip /;/ 
        end

        debug { "  keyword: #{keyword} #{keyword.position}" }
        debug { "  expression: #{expr} #{expr.position}" } if expr
        debug { "  block:\n#{block}\n#{block.position}"  } if block
        Directive.new keyword, expr, block
      end
      
      def parse_ruleset
        debug { 'parse ruleset' }

        selector = check(/\{/) ? nil : parse_selector
        skip /\{/
        declarations = parse_declarations
        skip /\}/
        
        RuleSet.new selector, declarations
      end
      
      def parse_selector
        debug { ' parse selector' }
        simple_selectors = batch(:parse_simple_selector, /\{/, /,/)
        Selector.new simple_selectors
      end

      def parse_simple_selector
        selector = scan R_SELECTOR 
        debug { '  parse simple selector' }
        debug { "   #{selector} #{selector.position}" }
        selector
      end
      
      def parse_declarations
        first = true
        batch(:parse_declaration) do
          if check /\}/
            false
          else 
            skip(first ? /[;\s]*/ : /[;\s]+/)
            first = false
            !check /\}/
          end
        end
      end
      
      def parse_declaration
        debug { '   parse declaration' }
        
        property = parse_property
        skip /:/
        value = parse_value
        
        Declaration.new(property, value)
      end
      
      def parse_property
        debug { '    parse property' }
        property = scan R_PROPERTY 
        debug { "     #{property} #{property.position}" }
        property
      end
      
      def parse_value
        debug { '    parse value' }

        value = scan R_ANY 
        debug { "     #{value} #{value.position}" }
        value 
      end

      def parse_comment
        debug { 'pare comment' }
        comment =  raw_scan /\/\*[^*]*\*+([^\/*][^*]*\*+)*\//
        debug { "  #{comment}" }
        comment
      end
     
      protected 

      #override
      def after_scan(pattern)
        do_parse_comment
      end

      def after_skip(pattern)
        do_parse_comment
      end

      private

      def do_parse_comment
        while true
          if check /\/\*/
            @comments << parse_comment
          else
            break
          end
        end
      end
      
    end
    
  end

end; end
