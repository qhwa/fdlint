$LOAD_PATH << File.dirname(File.expand_path(__FILE__))
require 'xray-test-css-star'

module XRayTest; module CSS; module Rule

    class AllTests
       def self.suite
         suite = Test::Unit::TestSuite.new
         suite << Star.new
         return suite
       end
    end

end; end; end
