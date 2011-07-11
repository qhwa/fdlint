# encoding: utf-8

require_relative '../../helper'

require 'node'
require 'css/struct'
require 'css/rule/check_list_rule'

module XRayTest
  module CSS
    module Rule
      
      class CheckEncodingTest < Test::Unit::TestCase

        def setup
          @runner = XRay::Runner.new :encoding => 'gb2312'
          @expect_err = XRay::LogEntry.new("File can't be read as gb2312 charset", :fatal) 
        end

        def test_check_utf8_file_well_written
          check_file "#{FIXTURE_PATH}/css/utf8_good.css"

          assert_equal true, has_encoding_error?, "utf-8文件默认不会去检查内容"
        end

        def test_check_utf8_file_with_errors
          check_file "#{FIXTURE_PATH}/css/utf8_using_star.css"

          assert_equal true, has_encoding_error?, "utf-8文件默认不会去检查内容"
        end

        def test_check_utf8_file_with_charset_declaraction
          check_file "#{FIXTURE_PATH}/css/utf8_good_declaring_charset.css"

          assert_equal false, has_encoding_error?, "带有@charset声明的文件应该可以被正确读取"
        end

        def test_check_gb2312_file_well_written
          check_file "#{FIXTURE_PATH}/css/gb_good.css"

          assert_equal false, has_encoding_error?, "GB2312的文件应该可以被正常读取"
        end

        def test_check_gb2312_file_with_errors
          check_file "#{FIXTURE_PATH}/css/gb_using_star.css"

          assert_equal false, has_encoding_error?, "GB2312的文件应该可以被正常读取"
          detected = @results.any? do |r|
            r.message.include? '禁止使用星号选择符'
          end
          assert detected, "check as usual"
        end
        
        private
        def check_file( file )
          good, @results = @runner.check_css_file file
        end

        def has_encoding_error?
          @results.any? do |r|
            r == @expect_err
          end
        end


      end

    end
  end
end
