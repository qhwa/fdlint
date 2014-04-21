require 'fdlint/encoding_error'
require 'fdlint/rule'
require 'fdlint/helper/code_type'
require 'fdlint/parser'
require 'fdlint/parser/js/js_parser'
require 'fdlint/parser/html/html_parser'
require 'fdlint/parser/css/css_parser'

module Fdlint

  class Validator

    attr_reader :file, :source, :results, :code_type
    include Fdlint::Helper::Logger

    def initialize( path = nil, options = {} )
      @file      = path
      @source    = options[:text]
      @code_type = options[:code_type] || Helper::CodeType.guess( source, file )
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

      yield file, source, results
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
        parser.parse_no_throw
        parser.results
      end

      def parser
        @parser ||= build_parser
      end

      def build_parser
        base_parser = {
          :js   => ::Fdlint::Parser::JS::JsParser,
          :css  => ::Fdlint::Parser::CSS::CssParser,
          :html => ::Fdlint::Parser::HTML::HtmlParser
        }.fetch( code_type ).new( source )

        file = File.new(self.file)
        base_parser.tap do |parser|
          content_level_rules.each do |validation|
            parser.add_visitor *validation.to_visitor( file: file )
          end
        end
      end

      def content_level_rules
        Fdlint::Rule.send( :"for_#{code_type}_content" )
      end

      def file_level_rules
        Fdlint::Rule.for_file( :code_type => code_type )
      end

  end

end
