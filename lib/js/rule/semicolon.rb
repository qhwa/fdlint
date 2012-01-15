# encoding: utf-8
require_relative '../../rule'

module XRay
  module JS
    module Rule
     
      class Semicolon

        include XRay::Rule
        
        def visit_statement(stat)
          check_js_statement stat
        end
         
      end
    
    end
  end
end
