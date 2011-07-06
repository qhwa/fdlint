require 'test/unit'
gem 'test-unit'
require 'test/unit/testsuite'
require_relative 'css/parser_test'

module XRayTest
    
    class ALL < Test::Unit::TestSuite
        
        def suite
            tests = []
            tests << CSS::ParserTest.new
            tests
        end
    end

end
