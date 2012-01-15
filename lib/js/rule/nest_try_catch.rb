# encoding: utf-8
require_relative 'helper'
require_relative '../../rule'

module XRay
  module JS
    module Rule
     
      class NestTryCatch 

        include XRay::JS::Rule::Helper, XRay::Rule

        def visit_stat_try(stat)
          check_js_stat_try stat
        end

         
      end
    
    end
  end
end
