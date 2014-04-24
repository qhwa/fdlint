# encoding: utf-8
require_relative '../helper'
require 'fdlint/parser/html/html_parser'
require 'fdlint/parser/html/query'

module FdlintTest
  module HTML

    class MixedTypeTest < Test::Unit::TestCase

      include FdlintTest::HTML

      def test_check_html_script_and_style
        src = %Q{<div class="mod">
                  <script> var a=1; </script>
                  <style>.mod {_font:arial;}</style>
                </div>}

        parse src do |results|
          assert_has_result results, [:error, '必须存在文档类型声明']
          assert_has_result results, [:error, '禁止使用未定义的变量(或全局变量)']
          assert_has_result results, [:error, '合理使用hack']
        end
      end

    end

  end
end
