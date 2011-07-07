# encoding: utf-8

require_relative '../../helper'

require 'node'
require 'css/struct'
require 'css/rule/check_list_rule'

module XRayTest
  module CSS
    module Rule
      
      class CheckEncodingRuleTest < Test::Unit::TestCase

        def setup
          @runner = XRay::Runner.new :encoding => 'gb2312'
        end

        def test_check_utf8_file_well_written
          file = "#{FIXTURE_PATH}/css/utf8_good.css"
          expect_err = LogEntry.new
          good, results = @runner.check_css_file file
          assert_equal false, good, "utf8 file will not pass"
          assert_equal [expect_err], results, "check should stop on encoding fatal"
        end

        def test_check_utf8_file_with_errors
          good, results = @runner.check_css_file "#{FIXTURE_PATH}/css/utf8_using_star.css"
          assert_equal false, good, "utf8 file will not pass"
          assert_equal [LogEntry.new], results, "check should stop on encoding fatal"
        end

        def test_check_gb2312_file_well_written
          good, results = @runner.check_css_file "#{FIXTURE_PATH}/css/utf8_good.css"
          assert_equal true, good, "GB2312 encoded file will pass"
          assert_equal nil, results, "check as usual"
        end

        def test_check_gb2312_file_with_errors
          good, results = @runner.check_css_file "#{FIXTURE_PATH}/css/gb2312_using_star.css"
          assert_equal true, good, "GB2312 encoded file will pass"
          assert_equal [], results, "check as usual"
        end

      end

    end
  end
end
