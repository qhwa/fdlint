require_relative '../../helper'

require 'js/parser'
require 'parser_visitable'

module XRayTest

  module JS
    module Rule

      class VisitableParser < XRay::JS::Parser
          include XRay::ParserVisitable 
      end

      class BaseTest < Test::Unit::TestCase

        def parse(js, action = 'parse_program')
          parser = XRay::JS::Parser.new js, XRayTest::Logger.new
          parser.send "parse_#{action}" 
        end 

        def parse_with_rule(js, klass, options = {})
          parser = VisitableParser.new js, XRayTest::Logger.new
          parser.add_visitor klass.new(options)
          parser.parse_program
          parser.results
        end
         
      end

    end
  end
end
