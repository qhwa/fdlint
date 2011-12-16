require_relative '../base_parser'
require_relative 'struct'

module XRay
  module CSS
    
    class Parser < XRay::BaseParser

      TERM = %q([^;{}'"])
      QUOT_EXPR = "#{TERM}*'[^']*'#{TERM}*"
      DQUOT_EXPR = %Q(#{TERM}*"[^"]*"#{TERM}*)
      R_EXPR = %r"(?:#{QUOT_EXPR})|(?:#{DQUOT_EXPR})|(?:#{TERM}+)"


      def parse_stylesheet(inner = false)
        log 'parse stylesheet'
        
        stats = batch(:parse_statement) do 
          skip_empty
          !(inner ? check(/\}/) : eos?)
        end
        
        StyleSheet.new(stats)
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
        keyword = scan /\w+/
        skip_empty

        expr = check(R_EXPR) ? scan(R_EXPR) : nil

        block = nil
        if check /\{/
          skip /\{/
          block = parse_stylesheet true
          skip /\}/
        end

        unless block
          skip /;/ 
        end

        skip_more_semicolon

        log "keyword: #{keyword} #{keyword.position}"
        log("expression: #{expr} #{expr.position}") if expr
        log("block: #{block} #{block.position}") if block
        Directive.new(keyword, expr, block)
      end
      
      def parse_ruleset
        log 'parse ruleset'

        selector = parse_selector
        skip /\{/
        declarations = parse_declarations
        skip /\}/
        
        log "ruleset parsed\n"
        RuleSet.new(selector, declarations)
      end
      
      def parse_selector
        log ' parse selector'
        simple_selectors = batch(:parse_simple_selector, /\{/)
        Selector.new simple_selectors
      end

      def parse_simple_selector
        log '   parse simple selector'
        selector = scan /[^,\{]+/

        check(/,/) && skip(/,/)

        log " [#{selector}] #{selector.position}"
        selector
      end
      
      def parse_declarations
        batch(:parse_declaration, /\}/)
      end
      
      def parse_declaration
        log '   parse declaration'
        
        property = parse_property
        skip /:/
        expression = parse_expression
        
        # 可选的分号
        semicolon = check(/\}/) ? /;?/ : /;/
        skip semicolon

        skip_more_semicolon

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

        expr = scan R_EXPR
        log "     [#{expr}] #{expr.position}"
        expr
      end
     
      protected 

      def filter_text(css)
        filter_css css
      end

      private
      
      def filter_css(css)
        filter_comment css
      end
      
      def filter_comment(css)
        re_comment = /\/\*[^*]*\*+([^\/*][^*]*\*+)*\//
        css.gsub(re_comment) do |m| 
          log "ignore comments: \n#{m}"
          m.gsub /\S/, ' '
        end
      end

      def skip_more_semicolon
        if check /;/
          skip /\s*;/
          parse_warn 'more than one semicolon'
        end
      end

    end
    
  end
end
