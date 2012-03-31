# encoding: utf-8
require 'test/unit'
require_relative '../helper'

module XRayTest

  module CLI

    class OutputFormatTest < Test::Unit::TestCase

      @@bin = File.expand_path(File.join File.dirname(__FILE__), '../../bin/fdlint')
      @@cmd = "ruby #{@@bin}"

      def test_with_console_format
        res = `#{@@cmd} #{FIXTURE_ABS_PATH}/css/empty.css`
        assert res.include? "[32m[OK][0m /home/qhwa/projects/fdlint/test/fixtures/css/empty.c"
      end

      def test_with_nocolor_format
        res = `#{@@cmd} --format=nocolor #{FIXTURE_ABS_PATH}/css/empty.css`
        assert res.include? "[OK] /home/qhwa/projects/fdlint/test/fixtures/css/empty.c"
      end

      def test_with_vim_format
        res = `#{@@cmd} --format=vim #{FIXTURE_ABS_PATH}/css/empty.css`
        assert res.empty?
      end

      def test_reulsts_with_vim_format
        res = `#{@@cmd} --format=vim #{FIXTURE_ABS_PATH}/css/using_expr.css`
        assert res.include? 'using_expr.css:[error]:5,7:禁止使用CSS表达式'
        assert res.include? 'using_expr.css:[error]:6,6:禁止使用CSS表达式'
      end

      unless `which cat`.empty?
        def test_results_with_vim_format_in_pipline
          res = `cat #{FIXTURE_ABS_PATH}/css/using_expr.css | #{@@cmd} --format=vim `
          assert res.include? '-:[error]:5,7:禁止使用CSS表达式'
          assert res.include? '-:[error]:6,6:禁止使用CSS表达式'
        end
      end

    end

  end

end
