require 'strscan'

require_relative '../parse_error'

module XRay
  module CSS
    
    StyleSheet = Struct.new(:rulesets)
    RuleSet = Struct.new(:selector, :declarations)
    Declaration = Struct.new(:property, :expression)
    
    
    class Parser
      attr_accessor :log
      
      def initialize(css, log = nil)
        @log = log
        
        log 'initialize'
        css = filter(css)
        @scanner = StringScanner.new(css)
      end

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
        log " [#{selector}]"
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
        log "     [#{property}]"
        property
      end
      
      def parse_expression
        log '     parse expression'
        quot_expr = "[^;}]*'[^']*'[^;}]*"
        dquot_expr = '[^;}]*"[^"]*"[^;}]*'
        term = '[^;}]+'
        
        expr = scan %r"(?:#{quot_expr})|(?:#{dquot_expr})|(?:#{term})"
        log "     [#{expr}]"
        expr
      end
      
      private
      
      def filter(css)
        filter_comment css
      end
      
      def filter_comment(css)
        re_comment = /\/\*[^*]*\*+([^\/*][^*]*\*+)*\//
        css.gsub(re_comment) do |m| 
          log "ignore comments: \n#{m}"
          ' ' * m.length
        end
      end

      def skip_empty
        @scanner.skip(/\s*/)
      end
      
      def pass(pattern)
        skip_empty
        unless @scanner.skip(pattern)
          raise ParseError
        end
      end
      
      def scan(pattern)
        skip_empty
        result = @scanner.scan(pattern)
        result ? result.strip : error
      end
      
      def batch(name, &block)
        result = []
        while (block ? block.call : true) && item = send(name)
          result << item
        end
        result
      end
      
      def error
        raise ParseError
      end
      
      def log(message)
        @log && @log.info('CSS Parser: ' + message)
      end
      
    end
    
  end
end