$LOAD_PATH << '.'
$LOAD_PATH << '../lib'
require 'xray'
require 'test/unit'
require 'xray-test-css'
require 'css/parser/xray-css-parser-test'

class XRayTest_All

    def self.suite
        suite = Test::Unit::TestSuite.new
        suite << XRayTest::CSS::Rule::AllTests.new
        suite << XRayTest::CSS::Parser::AllTests.new
        return suite
    end

end

