require_relative 'parser_visitable'

require_relative 'css/parser'
require_relative 'css/rule/check_list_rule'


module XRay

  class SimpleObserver

    attr_reader :results

    def initialize
      @results = []
      class << @results
        def print
            self.each { |r| puts r }
        end
      end
    end

    def update(result, parser)
      @results << result
    end

    def to_s
      @results.to_s
    end

    def success?
      @results.each do |r|
        if %w(fatal warn).include? r.level.to_s
          return false
        end
      end
      true
    end

  end


  class Runner

    CSS = XRay::CSS
  
    def initialize(opt={})
      logger = Logger.new(STDOUT)
      logger.level = opt[:debug] ? Logger::INFO : Logger::WARN
      @logger = logger
      @observer = SimpleObserver.new
    end

    def check_css(css)
      @text = css
      success = true
      parser = CSS::Parser.new(css, @logger)
      visitor = CSS::Rule::CheckListRule.new

      parser.add_visitor visitor
      parser.add_observer @observer

      begin
        parser.parse_stylesheet
      rescue ParseError => e
        success = false
        puts "#{e.message}#{e.position}"
      end

      [success && @observer.success? , @observer.results]
    end

    def check_js(text)
      true
    end

    def check_html(text)
      true
    end

  end
end
