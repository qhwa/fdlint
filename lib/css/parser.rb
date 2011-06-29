require_relative '../base_parser'
require_relative 'struct'

module XRay
  module CSS
    
    class Parser < XRay::BaseParser
      
      def parse_stylesheet
        log 'parse stylesheet'
        
        StyleSheet.new(parse_rulesets)
      end
      
      def parse_rulesets
        batch(:parse_ruleset)
      end
      
      def parse_ruleset
        log 'parse ruleset'
        
        skip_empty
        if @scanner.eos?
          log 'end of string, return nil'
          return nil
        end
        
        selector = parse_selector
        pass /\{/
        declarations = parse_declarations
        pass /}/
        
        log "ruleset parsed\n"
        RuleSet.new(selector, declarations)
      end
      
      def parse_selector
        log ' parse selector'
        selector = scan /[^\{]+/
        log " [#{selector}] #{selector.position}"
        selector
      end
      
      def parse_declarations
        batch(:parse_declaration) { !@scanner.check(/\s*}\s*/) }
      end
      
      def parse_declaration
        log '   parse declaration'
        
        property = parse_property
        pass /:/
        expression = parse_expression
        
        # 可选的分号
        semicolon = @scanner.check(/\s*}\s*/) ? /;?/ : /;/
        pass semicolon
        
        Declaration.new(property, expression)
      end
      
      def parse_property
        log '     parse property'
        property = scan /[^:]+/
        log "     [#{property}] #{property.position}"
        property
      end
      
      def parse_expression
        log '     parse expression'
        quot_expr = "[^;}]*'[^']*'[^;}]*"
        dquot_expr = '[^;}]*"[^"]*"[^;}]*'
        term = '[^;}]+'
        
        expr = scan %r"(?:#{quot_expr})|(?:#{dquot_expr})|(?:#{term})"
        log "     [#{expr}] #{expr.position}"
        expr
      end
     
      protected 

      def filter_text(css)
        filter_css(css)
      end

      private
      
      def filter_css(css)
        filter_comment css
      end
      
      def filter_comment(css)
        re_comment = /\/\*[^*]*\*+([^\/*][^*]*\*+)*\//
        css.gsub(re_comment) do |m| 
          log "ignore comments: \n#{m}"
          m.gsub(/\S/, ' ')
        end
      end

    end
    
  end
end
