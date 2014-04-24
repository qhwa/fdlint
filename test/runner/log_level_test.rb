# encoding: utf-8
require 'test/unit'
require_relative '../helper'

module FdlintTest

  module Runner

    class LogLevelTest < Test::Unit::TestCase

      def setup
        @html = fixture('html/mixed_log_levels.html')
      end

      def test_output_every_thing_by_default
        validate do |res|
          assert_contain( res, :fatal, :error, :warn )
        end
      end

      def test_output_fatals_only
        validate :fatal do |res|
          assert_contain( res, :fatal )
          assert_not_contain( res, :error, :warn )
        end
      end

      def _test_output_fatals_and_errors
        validate :error do |res|
          assert_contain( res, :fatal, :error )
          assert_not_contain( res, :error, :warn )
        end
      end

      def _test_output_fatals_errors_and_warnnings
        validate :warn do |res|
          assert_contain( res, :fatal, :error, :warn )
        end
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

        def validate log_level=nil
          yield Fdlint::Validator.new( nil, text: @html, log_level: log_level ).validate
        end

    end

  end

end
