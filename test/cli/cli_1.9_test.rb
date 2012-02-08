# encoding: utf-8
require 'test/unit'
require_relative '../helper'

module XRayTest

  module CLI

    class CLI19Test < Test::Unit::TestCase

      @@bin = File.expand_path(File.join File.dirname(__FILE__), '../../bin/fdlint')
      @@cmd = "ruby1.9.1 #{@@bin}"

      def test_check_html_file
        res = `#{@@cmd} #{FIXTURE_ABS_PATH}/html/syntax_err.html`
        assert res.index "[FATAL] [3,1]"
      end

      def test_check_css_file
        res = `#{@@cmd} #{FIXTURE_ABS_PATH}/css/using_star.css`
        assert res.include? '禁止使用星号选择符'
      end

      def test_check_js_file
        res = `#{@@cmd} #{FIXTURE_ABS_PATH}/js/scope-test.js`
        assert res.include? '[ERROR] [13,10] 禁止使用未定义的变量(或全局变量)'
        assert res.include? '[ERROR] [19,3] 禁止使用未定义的变量(或全局变量)'
      end

      unless `which cat`.empty?

        def test_check_html_text
          res = `cat #{FIXTURE_ABS_PATH}/html/syntax_err.html | #{@@cmd}`
          assert res.include? "[FATAL] [3,1]"
        end

        def test_check_css_text
          res = `cat #{FIXTURE_ABS_PATH}/css/using_star.css | #{@@cmd}`
          assert res.include? '禁止使用星号选择符'
        end

        def test_check_js_text
          res = `cat #{FIXTURE_ABS_PATH}/js/scope-test.js | #{@@cmd}`
          assert res.include? '[ERROR] [13,10] 禁止使用未定义的变量(或全局变量)'
          assert res.include? '[ERROR] [19,3] 禁止使用未定义的变量(或全局变量)'
        end

      end

    end

  end

end
