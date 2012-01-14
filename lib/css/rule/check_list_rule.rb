# encoding: utf-8

require_relative '../../rule'

module XRay
  module CSS
    module Rule

      class CheckListRule

        attr_reader :options

        include ::XRay::RuleHelper

        def initialize(options = {}) 
          @options = options
        end

        def visit_simple_selector(selector)
          check_css_selector selector
        end
        
        def visit_declaration(dec)
          check_declaration dec
        end

        def visit_ruleset(ruleset)
          check_css_ruleset ruleset
        end

        def visit_property(property)
          check_css_property property
        end

        def visit_value(value)
          check_css_value value
        end


      end

    end
  end
end
