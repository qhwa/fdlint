# encoding: utf-8

#require 'profile'

require 'logger'
require_relative 'base_parser'
require_relative 'parser_visitable'
require_relative 'file_validator'
require_relative 'log_entry'
require_relative 'css/reader'
require_relative 'css/parser'
require_relative 'css/rule/check_list_rule'
require_relative 'css/rule/check_file_name_rule'
require_relative 'css/rule/check_compression_rule'
require_relative 'html/parser'
require_relative 'html/rule/check_tag_rule'
require_relative 'js/parser'
require_relative 'js/rule/all'
require_relative 'helper/readfile'
require_relative 'helper/code_type'


module XRay

  module CSS
    class VisitableParser < Parser
      include XRay::ParserVisitable
    end
  end

  module HTML 
    class VisitableParser < Parser
      include XRay::ParserVisitable
    end
  end

  module JS
    class VisitableParser < Parser
      include XRay::ParserVisitable
    end
  end


  class Runner

    attr_reader :source
  
    def initialize(opt={})
      @opt = {
        :encoding => 'utf-8',
        :debug    => false
      }.merge opt

      @logger = Logger.new(STDOUT)
      @logger.level = @opt[:debug] ? Logger::INFO : Logger::WARN
    end

    def check_css(css, opt={})
      @source = css
      parser = XRay::CSS::VisitableParser.new(css, @logger)
      visitor = XRay::CSS::Rule::CheckListRule.new( opt )
      parser.add_visitor visitor
      run_parser parser
    end

    def check_css_file( file, opt={} )
      results = []
      begin
        file_val = FileValidator.new @opt.merge(opt)
        file_val.add_validator XRay::CSS::Rule::FileNameChecker.new( @opt.merge opt )
        file_val.add_validator XRay::CSS::Rule::CompressionChecker.new( @opt.merge opt )
        results.concat file_val.validate(file)

        source = XRay::CSS::Reader.read( file, @opt )
        results.concat check_css( source, opt.merge({
          :scope => CodeType.scope(file)
        }))
      rescue EncodingError => e
        results << LogEntry.new( "File can't be read as #{@opt[:encoding]} charset", :fatal)
      end
      results
    end

    def check_js(js)
      @source = js
      parser = JS::VisitableParser.new(js, @logger)
      rules = JS::Rule::All.new.rules
      rules.each do |rule|
        parser.add_visitor rule
      end
      run_parser parser
    end

    def check_js_file(file, opt = {})
      results = []
      begin
        source, encoding = readfile(file, opt)
        results.concat check_js(source)
      rescue  EncodingError => e
        results << LogEntry.new( "File can't be read as #{@opt[:encoding]} charset", :fatal)
      rescue => e
        if @opt[:debug]
          puts e
          puts e.backtrace 
        end
        results << LogEntry.new( e.to_s, :fatal )
      end
      results
    end

    def check_html(text, opt={})
      @source = text
      parser = HTML::VisitableParser.new(text, @logger)
      visitor = HTML::Rule::CheckTagRule.new( opt )
      parser.add_visitor visitor
      run_parser parser
    end

    def check_html_file(file, opt={})
      source, encoding = readfile file
      check_html source
    end

    def check_file( file )
      type = CodeType.guess_by_name(file)
      send( :"check_#{type}_file", file ) if CodeType.is_style_file? file
    end

    def check(text, filename="")
      type = CodeType.guess(text, filename)
      send :"check_#{type}", text
    end

    def valid_file? file
      CodeType.is_style_file?(file) and !minified_and_ignored(file) and type_ok?(file)
    end

    def minified_and_ignored(file)
      !@opt[:check_min] && file.to_s =~ /-min\.(css|js)$/
    end

    def type_ok?(file)
      return true if @opt[:type].nil?
      CodeType.guess_by_name(file) == @opt[:type]
    end

    def run_parser(parser)
      parser.parse_no_throw
      parser.results
    end

  end
end
