require_relative 'parser_visitable'

require_relative 'css/parser'
require_relative 'css/rule/check_list_rule'


module XRay

  class Runner

    CSS = XRay::CSS
  
    def initialize(opt={})
      logger = Logger.new(STDOUT)
      logger.level = opt[:debug] ? Logger::INFO : Logger::WARN
      @logger = logger
    end

    def check_css(css)
      parser = CSS::Parser.new(css, @logger)
      visitor = CSS::Rule::CheckListRule.new

      parser.add_visitor visitor

      begin
        parser.parse_stylesheet
      rescue ParseError => e
        success = false
        puts "#{e.message}#{e.position}"
      ensure
        results = parser.results
      end

      [success && success?(results) , results]
    end

    def check_js(text)
      true
    end

    def check_html(text)
      true
    end

    protected
    
    def success?(results)
      results.all { |r| ![:fatal, :warn].include?(r.level) }
    end

  end
end
