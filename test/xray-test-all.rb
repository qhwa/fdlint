$LOAD_PATH << '.'
require 'test/unit'
require 'xray-test-css'

class XRayTest_All

    def self.suite
        suite = Test::Unit::TestSuite.new
        suite << XRayTest_CSS_Star.new
        return suite
    end

end

