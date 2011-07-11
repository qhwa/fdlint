# encoding: utf-8
require_relative '../../helper'

require 'file_validator'
require 'css/rule/check_file_name_rule'

module XRayTest
  module CSS
    module Rule
      
      class CheckFileNameTest < Test::Unit::TestCase

        def setup
          @validator = XRay::FileValidator.new( :encoding => 'gb2312' )
          @validator.add_validator XRay::CSS::Rule::FileNameChecker.new
        end

        def test_file_name_with_ad
          file = 'aadd.css'
          good, results = @validator.check file

          expect_err = XRay::LogEntry.new("路径和文件名中不应该出现ad", :warn) 
          assert_equal false, good, "文件名中不应出现ad"
          assert_equal [expect_err], results
        end

        def test_path_name_with_ad
          file = "/css/admin/test.css"
          good, results = @validator.check file

          expect_err = XRay::LogEntry.new("路径和文件名中不应该出现ad", :warn) 
          assert_equal false, good, "文件路径中不应出现ad"
          assert_equal [expect_err], results, "文件路径中不应出现ad"
        end

        def test_file_name_without_ad
          file = 'not-exsiting-file.css'
          good, results = @validator.check file

          assert_equal true, good, "文件名中不应出现ad,包括路径"
        end

        def test_file_name_with_underscore
          file = 'not_exsiting_file.css'
          good, results = @validator.check file

          expect_err = XRay::LogEntry.new("文件名中单词的分隔符应该使用中横线“-”", :warn) 
          assert_equal false, good, "文件名中单词的分隔符应该使用中横线“-”"
          assert_equal [expect_err], results
        end

        def test_dir_name_with_minus
          file = 'test-post-offer/main.css'
          good, results = @validator.check file

          expect_err = XRay::LogEntry.new("文件夹只有需要版本区分时才可用中横线分隔，如fdev-v3", :warn) 
          assert_equal false, good, "文件夹只有需要版本区分时才可用中横线分隔"
          assert_equal [expect_err], results
        end

        def test_dir_name_with_version_minus
          file = 'test-2/main.css'
          good, results = @validator.check file

          assert_equal true, good, "目录名字中带有版本号时可以用中横线"
        end

      end

    end
  end
end

