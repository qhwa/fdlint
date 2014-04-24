# encoding: utf-8

require_relative '../helper'

require 'fdlint/parser/node'
require 'fdlint/log_entry'
require 'fdlint/parser/css/struct'

module FdlintTest
  module CSS
      
    class MacLineEndSupportTest < Test::Unit::TestCase

      def setup
      end

      def test_check_mac_line_end_with_good_css
        file = "#{FIXTURE_PATH}/css/mac-line-sep-good.css"
        assert_nothing_thrown "Mac style line end should be supported" do
          Fdlint::Validator.new( file ).validate
        end
      end

      def test_check_mac_line_end_with_error_css
        file = "#{FIXTURE_PATH}/css/mac-line-sep-err.css"
        assert_nothing_thrown "Mac style line end should be supported" do
          Fdlint::Validator.new( file ).validate
        end
      end


    end

  end
end

