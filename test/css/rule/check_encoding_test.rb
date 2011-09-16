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
          check_file "#{FIXTURE_PATH}/css/utf8_good.css" do |results|
            assert has_encoding_error?(results), "utf-8文件默认不会去检查内容"
          end
        end

        def test_check_utf8_file_with_errors
          check_file "#{FIXTURE_PATH}/css/utf8_using_star.css" do |results|
            assert has_encoding_error?(results), "utf-8文件默认不会去检查内容"
          end
        end

        def test_check_utf8_file_with_charset_declaraction
          check_file "#{FIXTURE_PATH}/css/utf8_good_declaring_charset.css" do |results|
            assert !has_encoding_error?(results), "带有@charset声明的文件应该可以被正确读取"
          end
        end

        def test_check_gb2312_file_well_written
          check_file "#{FIXTURE_PATH}/css/gb_good.css" do |results|
            assert !has_encoding_error?(results), "GB2312的文件应该可以被正常读取"
          end
        end

        def test_check_gb2312_file_with_errors
          check_file "#{FIXTURE_PATH}/css/gb_using_star.css" do |results|
            assert !has_encoding_error?(results), "GB2312的文件应该可以被正常读取"
            assert results.any? { |r| r.message.include? '禁止使用星号选择符' }
          end
        end
        
        private
        def check_file( file )
          good, results = @runner.check_css_file file
          yield results
        end

        def has_encoding_error?( results )
          results.include? @expect_err
        end


      end

    end
  end
end
