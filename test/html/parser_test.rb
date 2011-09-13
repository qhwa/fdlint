gem 'test-unit'
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'parser/parse_with_emtpy_test'
require_relative 'parser/parse_with_simple_tag_test'
require_relative 'parser/parse_with_selfclosing_test'
require_relative 'parser/parse_with_text_test'

module XRayTest
  
  module HTML

    class ParserTest < Test::Unit::TestSuite

      def self.suite
        tests = Test::Unit::TestSuite.new
        tests << Parser::ParseWithEmptyTest.suite
        tests << Parser::ParseWithSimpleTagTest.suite
        tests
      end
    end
  end
end

Test::Unit::UI::Console::TestRunner.run( XRayTest::HTML::ParserTest ) if __FILE__ == $0

