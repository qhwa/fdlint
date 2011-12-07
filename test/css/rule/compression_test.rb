# encoding: utf-8
require_relative '../../helper'

require 'file_validator'
require 'css/rule/check_compression_rule'

module XRayTest
  module CSS
    module Rule
      
      class CompressionTest < Test::Unit::TestCase

        def setup
          @validator = XRay::FileValidator.new( :encoding => 'gb2312' )
          @validator.add_validator XRay::CSS::Rule::CompressionChecker.new
        end

        def test_source_file_with_min
          file = "#{FIXTURE_PATH}/css/empty.css"
          good, results = @validator.check file

          assert good, "同目录下有min文件，测试应通过"
        end

        def test_source_file_without_min
          file = "#{FIXTURE_PATH}/css/import.css"
          good, results = @validator.check file

          expect_err = XRay::LogEntry.new('发布上线的文件需要压缩，命名规则如a.js->a-min.js，且两者在同一目录下', :error)
          assert !good, "同目录下没有对应的min文件，测试不应通过"
          assert_equal [expect_err], results, "同目录下没有对应的min文件，测试不应通过"
        end

        def test_merge_file
          file = 'merge.css'
          good, results = @validator.check file

          assert good, "merge文件不需要被压缩"
        end

        def test_min_file
          file = 'test-min.css'
          good, results = @validator.check file

          assert good, "本身已经被压缩，不需要再检查"
        end


      end

    end
  end
end

