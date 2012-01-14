# encoding: utf-8

require_relative 'helper'
require_relative '../lib/rule'

module XRayTest
  
  class RuleDSLTest < Test::Unit::TestCase

    include ::XRay::RuleHelper

    def setup
      @rule = Proc.new do |file|
        @called = true
        ["it's just a test", :warn]
      end
      @called = false
      clear_all_rules
      common
    end
    
    def test_add_file_checker
      check_file &@rule
      assert_contains file_rules, "available in common rules"
      assert_contains css_rules, "common rules available in css rules too"
      assert_contains css_file_rules, "common rules available in css file rules too"
      assert_not_contains only_css_file_rules, "not available in css rules only"
    end

    def test_add_css_file_checker
      css {
        check_file &@rule
      }
      assert_not_contains file_rules, "not available in common rules"
      assert_contains css_file_rules, "available in css rules"
      assert_contains only_css_file_rules, "available in css only rules"
    end

    def test_check
      check_file &@rule
      assert_equal check_file("test"), [["it's just a test", :warn]]
      assert @called
    end

    def test_named_checker
      msg = ['we suggest use "-" instead', :info]
      html {
        check_file_with_underline do |file|
          msg if file =~ /_/
        end
      }

      results = check_file_with_underline 'a_b.html'
      assert_equal msg, results
    end

    def test_normal_plus_named_checker
      case_warn = ['must use downcase filename', :error]
      check_file { |file| 
        case_warn if file =~ /[A-Z]/
      }

      msg = ['we suggest use "-" instead', :info]
      html {
        check_file_with_underline do |file|
          msg if file =~ /_/
        end
      }

      results = check_html_file 'a_B.html'
      assert_equal [case_warn, msg], results,
      
    end

    def assert_contains( rules, *msg )
      assert has_rule?(rules), *msg
    end

    def assert_not_contains( rules, *msg)
      assert !has_rule?(rules), *msg
    end

    def has_rule?( rules )
      rules.any? {|r| r[:block] == @rule }
    end

  end
end
