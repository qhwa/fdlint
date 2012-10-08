# encoding: utf-8
require 'test/unit'
require_relative '../helper'

module XRayTest

  module Runner

    class LogLevelTest < Test::Unit::TestCase

      def setup
        @runner = XRay::Runner.new
        @html = fixture('html/mixed_log_levels.html')
      end

      def test_output_every_thing_by_default
        res = @runner.check_html @html
        assert_contain( res, :fatal, :error, :warn )
      end

      def test_output_fatals_only
        @runner.log_level = :fatal
        res = @runner.check_html( @html )
        assert_contain( res, :fatal )
        assert_not_contain( res, :error, :warn )
      end

      def test_output_fatals_and_errors
        @runner.log_level = :error
        res = @runner.check_html( @html )
        assert_contain( res, :fatal, :error )
        assert_not_contain( res, :warn )
      end

      def test_output_fatals_errors_and_warnnings
        @runner.log_level = :warn
        res = @runner.check_html( @html )
        assert_contain( res, :fatal, :error, :warn )
      end

      private
      def assert_contain( results, *types )
        types.each do |type|
          assert( results.any? { |r| r.level == type } )
        end
      end

      def assert_not_contain( results, *types )
        types.each do |type|
          assert( ! (results.any? { |r| r.level == type } ) )
        end
      end

    end

  end

end
