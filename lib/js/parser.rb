require_relative '../base_parser'
require_relative 'struct'

require_relative 'expr/expr'
require_relative 'stat/stat'


module XRay
  module JS
    
    class Parser < XRay::BaseParser

      include Expr::Expr
      include Stat::Stat

      attr_reader :singleline_comments, :mutiline_comments

      def initialize(js, logger)
        super(js, logger)
        @singleline_comments, @mutiline_comments = [], []
      end

      def parse_program
        log 'parse program'
        parse_comments
        Program.new parse_source_elements
      end

      def parse_source_element
        log 'parse source_element'

        check(/function\b/) ? parse_function_declaration : parse_statement
      end

      def parse_function_declaration(skip_name = false)
        log 'parse function declaration'

        pos = skip /function/

        name = (skip_name && check(/\(/)) ? nil : parse_expr_identifier
        skip /\(/
        params = batch(:parse_expr_identifier, /\)/, /,/)
        skip /\)\s*\{/
        body = parse_source_elements true
        skip /}/
         
        FunctionDeclaraion.new name, Elements.new(params), body, pos
      end

      def parse_singleline_comment
        log 'parse singleline comment'
        comment = raw_scan /\/\/.*/
        log "  #{comment}"
        comment
      end

      def parse_mutiline_comment
        log 'parse mutiline comment'
        comment = raw_scan /\/\*[^*]*\*+([^\/*][^*]*\*+)*\//
        log "  #{comment}"
        comment
      end

      protected

      def create_element(klass, *args)
        elm = klass.new *args
        log "  #{elm.text} #{elm.position}"
        elm
      end

      #override
      def after_scan(pattern)
        parse_comments
      end

      def after_skip(pattern)
        parse_comments
      end

      private

      def parse_source_elements(inner = false)
        elms = batch(:parse_source_element) do
          skip_empty
          inner ? !check(/}/) : !eos? 
        end
        Elements.new elms
      end

      def parse_comments
        while true
          if check /\/\//
            @singleline_comments << parse_singleline_comment
          elsif check /\/\*/
            @mutiline_comments << parse_mutiline_comment
          else
            break
          end
        end
      end

    end

  end
end
