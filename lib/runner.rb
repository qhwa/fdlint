require 'logger'
require_relative 'parser_visitable'
require_relative 'log_entry'
require_relative 'css/parser'
require_relative 'css/rule/check_list_rule'


module XRay

  class SimpleObserver

    attr_reader :results

    def initialize
      @results = []
    end

    def update(result, parser)
      @results << result
    end

  end


  class Runner

    CSS = XRay::CSS
  
    def initialize(opt={})
      @opt = {
        :encoding => 'utf-8',
        :debug    => false
      }.merge opt

      @logger = Logger.new(STDOUT)
      @logger.level = @opt[:debug] ? Logger::INFO : Logger::WARN
      @observer = SimpleObserver.new
      @results = []
    end

    def check_css(css)
      @text = css
      no_error = true
      parser = CSS::Parser.new(css, @logger)
      visitor = CSS::Rule::CheckListRule.new

      parser.add_visitor visitor
      parser.add_observer @observer

      begin
        parser.parse_stylesheet
      rescue ParseError => e
        no_error = false
        puts "#{e.message}#{e.position}"
      end

      @results = @observer.results
      [no_error && success? , @results]
    end

    def check_css_file( file )
      begin
        text = IO.read(file, :encoding => @opt[:encoding].to_s)
        text.encode! 'utf-8'
        @source = text
        check_css text
      rescue Encoding::UndefinedConversionError => e
        @results = [VisitResult.new( nil, "File can't be read as #{@opt[:encoding]} charset", :fatal)]
        return [false, @results]
      rescue => e
        @results = [VisitResult.new( nil, e.to_s, :fatal )]
        return [false, @results]
      end
    end

    def check_js(text)
      true
    end

    def check_html(text)
      true
    end

    def check_file( file )
      send :"check_#{get_file_type file}_file", file
    end

    def print_results
      @results.each { |r| puts r }
    end

    def print_results_with_source
      if @source
        lines = @source.split("\n")
        @results.each do |r|
          pos = r.node.position
          puts lines[pos.line]
          puts ' ' * pos.column << '^ ' << r.to_color_s
          puts "\n"
        end
      else
        print_results
      end
    end

    def success?
      @results.each do |r|
        if %w(fatal error warn).include? r.level.to_s
          return false
        end
      end
      true
    end

    def get_file_type( name )
      if name =~ /\.css$/i
        :css
      elsif name =~ /\.js/i
        :js
      else
        :html
      end
    end

    protected :get_file_type

  end
end
