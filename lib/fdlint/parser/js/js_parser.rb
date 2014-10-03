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
        debug { 'parse program' }
        parse_comments
        Program.new parse_source_elements
      end

      alias_method :parse, :parse_program

      def parse_source_element
        debug { 'parse source_element' }

        check(FUNCTION) ? parse_function_declaration : parse_statement
      end

      FUNCTION              = /function\b/.freeze
      LEFT_BRACKET          = /\(/.freeze
      FUNCTION_ENDING       = /\)\s*\{/.freeze
      RIGHT_PARENT_BRACKET  = /\}/.freeze
      SINGLELINE_COMMENT    = %r{//.*}.freeze
      MULTILINE_COMMENT_REG = %r{/\*[^*]*\*+([^\/*][^*]*\*+)*/}.freeze

      def parse_function_declaration(skip_name = false)
        debug { 'parse function declaration' }

        pos = skip /function/

        name = (skip_name && check(LEFT_BRACKET)) ? nil : parse_function_name
        skip LEFT_BRACKET
        params = parse_function_parameters
        skip FUNCTION_ENDING
        body = parse_source_elements true
        skip RIGHT_PARENT_BRACKET
         
        FunctionDeclaraion.new name, params, body, pos
      end

      def parse_function_name
         parse_expr_identifier
      end

      def parse_function_parameters
        Elements.new batch(:parse_expr_identifier, /\)/, /,/)
      end

      def parse_singleline_comment
        debug { 'parse singleline comment' }
        comment = raw_scan SINGLELINE_COMMENT
        comment
      end

      def parse_mutiline_comment
        debug { 'parse mutiline comment' }
        comment = raw_scan MULTILINE_COMMENT_REG 
        comment
      end

      protected

      def create_element(klass, *args)
        elm = klass.new *args
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
          inner ? !check(RIGHT_PARENT_BRACKET) : !eos? 
        end
        Elements.new elms
      end

      SINGLELINE_COMMENT_STARTING = %r{//}.freeze
      MUTILINE_COMMENT_STARTING   = %r{/\*}.freeze
      def parse_comments
        while true
          if check SINGLELINE_COMMENT_STARTING
            @singleline_comments << parse_singleline_comment
          elsif check MUTILINE_COMMENT_STARTING
            @mutiline_comments << parse_mutiline_comment
          else
            break
          end
        end
      end

    end

  end

end; end
