require_relative '../../helper'

require 'fdlint/parser/js/js_parser'
require 'fdlint/parser/parser_visitable'

module FdlintTest

  module JS
    module Rule

      class VisitableParser < Fdlint::Parser::JS::JsParser
      end

      class BaseTest < Test::Unit::TestCase
        include FdlintTest::JS
      end

    end
  end
end
