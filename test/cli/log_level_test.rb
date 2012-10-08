# encoding: utf-8
require 'test/unit'
require_relative '../helper'

module XRayTest

  module CLI

    class LogLevelTest < Test::Unit::TestCase

      def setup
        @bin = File.expand_path(File.join File.dirname(__FILE__), '../../bin/fdlint')
        @fixture = File.expand_path(File.join File.dirname(__FILE__), '../fixtures/html/mixed_log_levels.html')
        @cmd = "ruby #{@bin} #{@fixture}"
      end

      unless `which cat`.empty?
        def test_output_all_by_default
          res = `#{@cmd}`
          assert res.include? 'WARN'
          assert res.include? 'ERROR'
          assert res.include? 'FATAL'
        end

        def test_output_fatals
          res = `#{@cmd} --level=fatal`
          assert !res.include?('WARN')
          assert !res.include?('ERROR')
          assert res.include? 'FATAL'
        end

        def test_output_fatals_and_errors
          res = `#{@cmd} --level=error`
          assert !res.include?('WARN')
          assert res.include?('ERROR')
          assert res.include? 'FATAL'
        end

        def test_output_fatals_errors_and_warnings
          res = `#{@cmd} --level=warn`
          assert res.include?('WARN')
          assert res.include?('ERROR')
          assert res.include? 'FATAL'
        end
      end
    end

  end

end

