require 'test/unit'
require 'cls-xray-test'
require 'cls-xray-test-rule'
require 'css/xray-test-css-star'

module XRayTest; module CSS; module Rule

    class AllTests
       def self.suite
         suite = Test::Unit::TestSuite.new
         suite << Star.new
         return suite
       end
    end

end; end; end
