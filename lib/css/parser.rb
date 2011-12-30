require_relative '../base_parser'
require_relative 'struct'

module XRay
  module CSS
    
    class Parser < XRay::BaseParser
      TERM = %q([^;{}'"])
      TERM2 = %q([^;{}'",])
      QUOT_EXPR = "'[^']*'"
      DQUOT_EXPR = '"[^"]*"'

      R_IDENT = /-?[_a-z][_a-z0-9-]*/
      R_ANY = %r"((?:#{TERM})|(?:#{QUOT_EXPR})|(?:#{DQUOT_EXPR}))+"
      R_SELECTOR = %r"((?:#{TERM2})|(?:#{QUOT_EXPR})|(?:#{DQUOT_EXPR}))+"

      attr_reader :comments

      def initialize(css, logger)
        super
        @comments = []
      end

      def parse_stylesheet(inner = false)
        log 'parse stylesheet'
        
        do_parse_comment

        stats = batch(:parse_statement) do 
          skip_empty
          !(inner ? check(/\}/) : eos?)
        end
        
        StyleSheet.new stats
      end

      # ruleset or directive
      def parse_statement
        log 'parse statement'

        if check /@/
          parse_directive
        else
          parse_ruleset
        end
      end

      def parse_directive
        log 'parse directive'

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

        log "  keyword: #{keyword} #{keyword.position}"
        log("  expression: #{expr} #{expr.position}") if expr
        log("  block:\n#{block}\n#{block.position}") if block
        Directive.new keyword, expr, block
      end
      
      def parse_ruleset
        log 'parse ruleset'

        selector = check(/\{/) ? nil : parse_selector
        skip /\{/
        declarations = parse_declarations
        skip /\}/
        
        RuleSet.new selector, declarations
      end
      
      def parse_selector
        log ' parse selector'
        simple_selectors = batch(:parse_simple_selector, /\{/, /,/)
        Selector.new simple_selectors
      end

      def parse_simple_selector
        log '  parse simple selector'
        selector = scan R_SELECTOR 
        log "   #{selector} #{selector.position}"
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
        log '   parse declaration'
        
        property = parse_property
        skip /:/
        value = parse_value
        
        Declaration.new(property, value)
      end
      
      def parse_property
        log '    parse property'
        property = scan R_IDENT 
        log "     #{property} #{property.position}"
        property
      end
      
      def parse_value
        log '    parse value'

        value = scan R_ANY 
        log "     #{value} #{value.position}"
        value 
      end

      def parse_comment
        log 'pare comment'
        comment =  raw_scan /\/\*[^*]*\*+([^\/*][^*]*\*+)*\//
        log "  #{comment}" 
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
end
