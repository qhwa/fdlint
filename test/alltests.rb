$LOAD_PATH << '.'
$LOAD_PATH << '../lib'
require 'xray'
require 'test/unit'
require 'cls-xray-test'
require 'cls-xray-test-rule'
require 'css/alltests'
require 'css/parser/alltests'

class XRayTest_All

    def self.suite
        suite = Test::Unit::TestSuite.new
        suite << XRayTest::CSS::Rule::AllTests.new
        suite << XRayTest::CSS::Parser::AllTests.new
        return suite
    end

end

