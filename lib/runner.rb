# encoding: utf-8

#require 'profile'

require 'logger'
require_relative 'base_parser'
require_relative 'rule'
require_relative 'parser_visitable'
require_relative 'file_validator'
require_relative 'log_entry'
require_relative 'css/reader'
require_relative 'css/parser'
require_relative 'css/rule/checklist'
require_relative 'html/parser'
require_relative 'html/rule/check_tag_rule'
require_relative 'html/rule/check_link_rule'
require_relative 'js/parser'
require_relative 'js/rule/all'
require_relative 'js/rule/file_checker'
require_relative 'helper/file_reader'
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
    
    include Helper::FileReader

    attr_reader :source, :rules
  
    def initialize(opt={})
      @opt = {
        :encoding => 'utf-8',
        :debug    => false,
        :log_level => :warn
      }.merge opt

      @rules = []

      if @opt[:debug]
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
      end

      Rule.import_all


    end

    def check_css(css, opt = {})
      @source              = css
      parser               = XRay::CSS::VisitableParser.new(css, @logger)
      visitor              = XRay::CSS::Rule::CheckListRule.new( opt )
      parser.add_visitor visitor
      run_parser( parser )
    end

    def check_css_file( file, opt={} )
      results = []
      begin
        "".extend(XRay::Rule).check_css_file(file).each do |msg, level, *pos|
          results.unshift LogEntry.new( msg, level, pos[0] || 0, pos[1] || 0 )
        end

        source = XRay::CSS::Reader.read( file, @opt )
        results.concat check_css( source, opt.merge({
          :scope => CodeType.scope(file)
        }))
      rescue EncodingError => e
        results.unshift LogEntry.new( "File can't be read as #{@opt[:encoding]} charset", :fatal)
      rescue => e
        if @opt[:debug]
          puts e
          puts e.backtrace 
        end
        results.unshift LogEntry.new( e.to_s, :fatal)
      end
      results
    end

    def check_js(js, opt={})
      @source = js
      parser = JS::VisitableParser.new(js, @logger)
      parser.add_visitors JS::Rule::All.new
      run_parser( parser )
    end

    def check_js_file(file, opt = {})
      results = []
      begin
        results.concat JS::Rule::FileChecker.new.check_file(file)

        source, encoding = readfile(file, opt)
        results.concat check_js(source)
      rescue  EncodingError => e
        results.unshift LogEntry.new( "File can't be read as #{@opt[:encoding]} charset", :fatal)
      rescue => e
        if @opt[:debug]
          puts e
          puts e.backtrace 
        end
        results.unshift LogEntry.new( e.to_s, :fatal )
      end
      results
    end

    def check_html(text, opt={})
      @source = text

      parser = HTML::VisitableParser.new(text, @logger)
      visitor = HTML::Rule::CheckTagRule.new(opt)
      parser.add_visitor visitor
      visitor = HTML::Rule::CheckLinkRule.new(opt)
      parser.add_visitor visitor

      results = run_parser( parser )
      unless @parsed_element.nil? or @parsed_element.empty?
        results += check_scripts_in_html(opt)
        results += check_styles_in_html(opt)
      end
      results
    end

    def check_scripts_in_html(opt={})
      results = []
      @parsed_element.query('script') do |script|
        row = script.position.row
        col = script.position.column
        Runner.new.check_js(script.text, opt).each do |ret|
          ret.column += script.outer_html[/^\s*<script*?>/].size if ret.row == 1
          ret.row += row - 1
          results << ret
        end
      end

      results
    end

    def check_styles_in_html(opt={})
      results = []
      @parsed_element.query('style') do |style|
        row = style.position.row
        col = style.position.column
        Runner.new.check_css(style.text, opt.merge({:scope => :in_page })).each do |ret|
          ret.column += style.outer_html[/^\s*<style*?>/].size if ret.row == 1
          ret.row += row - 1
          results << ret
        end
      end

      results
    end

    def check_html_file(file, opt={})
      source, encoding = readfile file
      check_html source, opt
    end

    def check_file(file, opts = {})
      type = CodeType.guess_by_name(file)
      send( "check_#{type}_file", file, opts) if CodeType.is_style_file? file
    end

    def check(text, filename="", opts = {})
      type = CodeType.guess(text, filename)
      send "check_#{type}", text, opts
    end

    def valid_file? file
      CodeType.is_style_file?(file) and !minified_and_ignored(file) and type_ok?(file)
    end

    def minified_and_ignored(file)
      !@opt[:check_min] && file.to_s =~ /-min\.(css|js)$/
    end

    def type_ok?(file)
      if @opt[:type]
        CodeType.guess_by_name(file) == @opt[:type]
      else
        true
      end
    end

    def run_parser(parser)
      @parsed_element = parser.parse_no_throw
      filter_results( parser.results ).sort_by!(&:row)
    end

    def filter_results(results)
      case log_level
        when :warn
          results
        when :error
          results.select {|r| r.level == :error || r.level == :fatal }
        when :fatal
          results.select {|r| r.level == :fatal }
      end
    end

    def log_level
      @opt[:log_level]
    end

    def log_level=(lvl)
      @opt[:log_level] = lvl
    end

  end
end
