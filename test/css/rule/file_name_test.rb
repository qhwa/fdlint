# encoding: utf-8

require_relative '../../helper'

require 'fdlint/parser/node'
require 'fdlint/parser/css/struct'

module FdlintTest
  module CSS
    module Rule
      
      class CheckFileNameTest < Test::Unit::TestCase

        def setup
          Fdlint::Rule.all
        end

        def test_file_name_with_ad
          check fixture_path('css/ad.css') do |results|
            assert_has_result results, [:error, "路径和文件名中不应该出现ad"] 
          end
        end

        def test_path_name_with_ad
          check fixture_path( "css/adver/test.css" ) do |results|
            assert_has_result results, [:error, "路径和文件名中不应该出现ad"] 
          end
        end

        def test_file_name_with_underscore
          check fixture_path( 'css/using_id.css' ) do |results|
            assert_has_result results, [:warn, "文件名中的连字符建议使用“-”而不是“_”"] 
          end
        end

        def test_file_name_with_upcase
          check fixture_path( 'css/camelCase.css' ) do |results|
            assert_has_result results, [:error, "文件夹和文件命名必须用小写字母"] 
          end
        end

        protected

          def check(file, &block)
            Fdlint::Validator.new( file ).tap do |validator|
              validator.validate_file
              yield validator.results
            end
          end

      end

    end
  end
end
