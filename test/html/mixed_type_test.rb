# encoding: utf-8
require_relative '../helper'
require 'html/parser'
require 'html/query'

module XRayTest
  module HTML

    class MixedTypeTest < Test::Unit::TestCase

      def setup
        @runner = ::XRay::Runner.new
      end
      
      def test_check_html_script_and_style
        html = %Q{<div class="mod">
<script> var a=1; </script>
<style>.mod {_font:arial;}</style>
          </div>}

        results = @runner.check_html( html )
        assert results.any? {|ret| ret.message == '必须存在文档类型声明' }
        assert results.any? {|ret| ret.message == '不允许使用全局变量' && ret.row ==2 && ret.column == 10 }
        assert results.any? {|ret| ret.message == '合理使用hack' && ret.row == 3 && ret.column == 14 }
      end

      private
      def parse(html)
        ::XRay::HTML::Parser.parse html
      end

    end

  end
end
