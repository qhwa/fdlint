require_relative '../../helper'

require 'js/parser'

module XRayTest

  module JS
    module Rule

      class BaseTest < Test::Unit::TestCase

        def parse(js, action)
          parser = XRay::JS::Parser.new js, Logger.new(STDOUT)
          parser.send "parse_#{action}" 
        end 
         
      end

    end
  end
end
