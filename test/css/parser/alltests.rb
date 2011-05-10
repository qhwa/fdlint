# CSS parser test suite
$LOAD_PATH << File.dirname(File.expand_path( __FILE__ ) )
require 'test_simple'

module XRayTest; module CSS; module Parser

    class AllTests
        def self.suite
            suite = Test::Unit::TestSuite.new
            suite << SimpleTest.new 
            return suite
        end
    end

end; end; end
