# encoding: utf-8

require_relative 'helper'

module XRayTest
  
  class RuleDSLTest < Test::Unit::TestCase

    @test_log = ["it's just a test", :warn]

    def setup
      @runner = XRay::Runner.new
    end
    
    def test_add_file_checker
      check_file do |file|
        @test_log
      end

      assert @runner.file_rules.include?(@test_log), "add normal file check rule"
    end

    def test_add_css_file_checker
      check_css_file do |file|
        @test_log
      end
      assert @runner.css_file_rules.include?(@test_log), "add css file check rule"
    end

  end
end
