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

    def run
      check_css '* html {}'
    end

    def check_css(css)
      parser = CSS::Parser.new css
      visitor = CSS::Rule::CheckListRule.new
      observer = SimpleObserver.new

      parser.add_visitor visitor
      parser.add_observer observer

      parser.parse_stylesheet
    end

    def check_js(text)
      true
    end

    def check_html(text)
      true
    end

  end
end

if __FILE__ == $0
  runner = XRay::Runner.new
  runner.run
end
