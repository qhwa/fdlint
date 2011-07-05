require_relative 'base_parser'
require_relative 'parser_visitable'

require_relative 'css/parser'
require_relative 'css/rule/check_list_rule'


module XRay
  class BaseParser
    include ParserVisitable
  end

  class SimpleObserver
    def update(result, parser)
      puts "#{result}"
    end
  end


  class Runner

    CSS = XRay::CSS
  
    def initialize(logger = nil)
      @logger = logger
    end

    def check_css(css)
      parser = CSS::Parser.new(css, @logger)
      visitor = CSS::Rule::CheckListRule.new
      observer = SimpleObserver.new

      parser.add_visitor visitor
      parser.add_observer observer

      begin
        parser.parse_stylesheet
      rescue ParseError => e
        puts "#{e.message}#{e.position}"
      end
    end

    def check_js(text)
      true
    end

    def check_html(text)
      true
    end

  end
end
