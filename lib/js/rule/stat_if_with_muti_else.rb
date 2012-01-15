# encoding: utf-8
require_relative '../../rule'

module XRay
  module JS
    module Rule
     
      class StatIfWithMutiElse

        include XRay::Rule
        
        def visit_stat_if(stat)
          check_js_stat_if stat
        end
         
      end
    
    end
  end
end
