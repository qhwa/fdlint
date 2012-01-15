# encoding: utf-8

require_relative '../../helper'

require 'node'
require 'css/struct'
require 'css/rule/checklist'

module XRayTest
  module CSS
    module Rule
      
      class CheckFileNameTest < Test::Unit::TestCase

        include XRay::Rule

        def setup
        end

        def test_file_name_with_ad
          check 'css/ad.css' do |results|
            expect_err = ["路径和文件名中不应该出现ad", :error]
            assert_equal [expect_err], results, "文件名中不应出现ad"
          end
        end

        def test_path_name_with_ad
          check "/css/adver/test.css" do |results|
            expect_err = ["路径和文件名中不应该出现ad", :error] 
            assert_equal [expect_err], results, "文件路径中不应出现ad"
          end
        end

        def test_file_name_without_ad
          check 'not-exsiting-file.css' do |results|
            assert results.empty?, "文件名中不应出现ad,包括路径"
          end
        end

        def test_file_name_with_underscore
          check 'not_exsiting_file.css' do |results|
            expect_err = ["文件名中单词的分隔符应该使用中横线“-”", :error] 
            assert_equal [expect_err], results, "文件名中单词的分隔符应该使用中横线“-”"
          end
        end

        def test_file_name_with_upcase
          check 'someFile.css' do |results|
            expect_err = ["文件夹和文件命名必须用小写字母", :error] 
            assert_equal [expect_err], results, "文件夹和文件命名必须用小写字母"
          end
        end

        def test_dir_name_with_minus
          check 'test-post-offer/main.css' do |results|
            expect_err = ["文件夹只有需要版本区分时才可用中横线分隔，如fdev-v3", :error] 
            assert_equal [expect_err], results, "文件夹只有需要版本区分时才可用中横线分隔"
          end
        end

        def test_dir_name_with_version_minus
          check 'test-2/main.css' do |results|
            assert results.empty?, "目录名字中带有版本号时可以用中横线"
          end
        end

        protected
        def check(file, &block)
          yield check_css_file(file)
        end

      end

    end
  end
end
