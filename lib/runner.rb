require 'logger'
require_relative 'parser_visitable'
require_relative 'log_entry'
require_relative 'css/parser'
require_relative 'css/rule/check_list_rule'


module XRay

  class Runner

    CSS = XRay::CSS
  
    def initialize(opt={})
      @opt = {
        :encoding => 'utf-8',
        :debug    => false
      }.merge opt

      @logger = Logger.new(STDOUT)
      @logger.level = @opt[:debug] ? Logger::INFO : Logger::WARN
      @results = []
    end

    def check_css(css, opt={})
      @text = css
      no_error = true
      parser = CSS::Parser.new(css, @logger)
      visitor = CSS::Rule::CheckListRule.new( opt )

      parser.add_visitor visitor

      begin
        parser.parse_stylesheet
      rescue ParseError => e
        no_error = false
        puts "#{e.message}#{e.position}"
      ensure
        @results = parser.results
      end

      [no_error && success? , @results]
    end

    def check_css_file( file, opt={} )
      begin
        text = IO.read(file, :encoding => @opt[:encoding].to_s)
        text.encode! 'utf-8'
        @source = text
        check_css text, opt.merge({
          :scope => file =~ /[\\\/]lib[\\\/]/ ? 'lib' : 'page'
        })
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

    def check_js_file(file)
      true
    end

    def check_html(text)
      true
    end

    def check_html_file(file)
      true
    end

    def check_file( file )
      send( :"check_#{Runner.get_file_type file}_file", file ) if Runner.style_file? file
    end

    def print_results( opt={} )
      prf = opt[:prefix] || ''
      suf = opt[:suffix] || ''
      @results.each { |r| puts prf + r.to_s + suf }
    end

    def print_results_with_source( opt )
      if @source
        lines = @source.split("\n")
        prf = opt[:prefix] || ''
        suf = opt[:suffix] || ''
        @results.each do |r|
          pos = r.node.position
          line_t = lines[pos.line]
          left = pos.column - 50
          right = pos.column + 50
          left = 0 if left < 0
          puts prf + lines[pos.line][left..right]
          puts prf + ' ' * (pos.column - left) << '^ ' << r.to_color_s
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

    def self.get_file_type( name )
      f = File.extname( name )
      if f =~ /\.css$/i
        :css
      elsif f =~ /\.js/i
        :js
      else
        :html
      end
    end

    def self.style_file?( name )
      File.extname( name ) =~ /(css|js|html?)$/i
    end

  end
end
