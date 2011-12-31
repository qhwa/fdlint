require_relative '../../helper'

require 'js/rule/all'

module XRayTest
  module JS
    module Rule
      
      class AllTest < Test::Unit::TestCase
        
        def test_initialize
          all = XRay::JS::Rule::All.new
          
          assert all.respond_to?(:each)
          assert all.size > 0
          assert all.size == all.rules.size
        end 

      end

    end
  end
end
