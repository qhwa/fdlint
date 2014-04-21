require 'fdlint/parser/base_parser'
require 'fdlint/parser/js/struct'
require 'fdlint/parser/js/expr/expr'
require 'fdlint/parser/js/stat/stat'


module Fdlint; module Parser

  module JS
    
    class JsParser < Fdlint::Parser::BaseParser

      include Expr::Expr
      include Stat::Stat
      include ::Fdlint::Parser::ParserVisitable

      attr_reader :singleline_comments, :mutiline_comments

      def initialize(js)
        super
        @singleline_comments, @mutiline_comments = [], []
      end

      def parse_program
        log 'parse program'
        parse_comments
        Program.new parse_source_elements
      end

      alias_method :parse, :parse_program

      def parse_source_element
        log 'parse source_element'

        check(/function\b/) ? parse_function_declaration : parse_statement
      end

      def parse_function_declaration(skip_name = false)
        log 'parse function declaration'

        pos = skip /function/

        name = (skip_name && check(/\(/)) ? nil : parse_function_name
        skip /\(/
        params = parse_function_parameters
        skip /\)\s*\{/
        body = parse_source_elements true
        skip /\}/
         
        FunctionDeclaraion.new name, params, body, pos
      end

      def parse_function_name
         parse_expr_identifier
      end

      def parse_function_parameters
        Elements.new batch(:parse_expr_identifier, /\)/, /,/)
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
          inner ? !check(/\}/) : !eos? 
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

end; end
