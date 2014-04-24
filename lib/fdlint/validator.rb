require 'fdlint/rule'
require 'fdlint/helper/file_reader'
require 'fdlint/helper/code_type'
require 'fdlint/parser'
require 'fdlint/parser/js/js_parser'
require 'fdlint/parser/html/html_parser'
require 'fdlint/parser/css/css_parser'

module Fdlint

  class Validator

    attr_reader :file, :source, :results, :syntax, :log_level

    include Fdlint::Helper::Logger

    def initialize( path = nil, options = {} )
      @file      = path
      @source    = options[:text]
      @syntax    = options[:syntax] || Helper::CodeType.guess( source, file )
      @log_level = options[:log_level]
    end

    def validate
      @results = []

      begin
        @source ||= read_file

        validate_file if file
        validate_content
      rescue EncodingError
        results << InvalidFileEncoding.new
      end

      filter_results_by_log_level if log_level

      if block_given?
        yield file, source, results
      else
        results
      end
    end

    def validate_file
      debug { "validating file: " << file }
      file = File.new( self.file )
      entries = file_level_rules.map do |validation|
        validation.exec( file, source, file )
      end
      self << entries.flatten.compact
    end

    def validate_content
      if source.valid_encoding?
        self << parse.flatten
      else
        self << [InvalidFileEncoding.new]
      end
    end

    protected

      def << results
        @results ||= []
        if results
          @results.concat results
        end
        @results
      end

      def read_file
        ::Fdlint::Helper::FileReader.readfile( file, force_utf8: true )
      end

      def parse
        root = parser.parse_no_throw
        parser.results.tap do |results|
          if root.respond_to? :query
            parse_inline_script( root, results )
            parse_inline_stylesheet( root, results )
          end
        end
      end

      def parse_inline_script( root, results )
        root.query('script') do |script|

          next if script.has_prop?( :src )

          script_row = script.position.row
          script_col = script.outer_html[/^\s*<script*?>/i].size
          src        = script.text

          Validator.new( nil,  :text => src, :syntax => :js ).validate.each do |ret|
            ret.column += script_col if ret.row == 1
            ret.row    += script_row - 1
            results << ret
          end
        end
      end

      def parse_inline_stylesheet( root, results )
        root.query('style') do |style|

          style_row = style.position.row
          style_col = style.outer_html[/^\s*<style*?>/i].size
          src       = style.text

          Validator.new( nil,  :text => src, :syntax => :css ).validate.each do |ret|
            ret.column += style_col if ret.row == 1
            ret.row    += style_row - 1
            results << ret
          end
        end
      end

      def parser
        @parser ||= build_parser
      end

      def build_parser
        base_parser = {
          :js   => ::Fdlint::Parser::JS::JsParser,
          :css  => ::Fdlint::Parser::CSS::CssParser,
          :html => ::Fdlint::Parser::HTML::HtmlParser
        }.fetch( syntax ).new( source )

        file = File.new(self.file) if self.file

        base_parser.tap do |parser|
          content_level_rules.each do |validation|
            parser.add_visitor *validation.to_visitor( file: file )
          end
        end
      end

      def content_level_rules
        Fdlint::Rule.send( :"for_#{syntax}_content" )
      end

      def file_level_rules
        Fdlint::Rule.for_file( :syntax => syntax )
      end

      def filter_results_by_log_level
        @results.select! do |r|
          LogEntry.level_greater_or_equal? r.level, log_level
        end
      end

  end

end
