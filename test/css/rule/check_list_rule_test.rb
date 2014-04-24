# encoding: utf-8

require_relative '../../helper'

require 'fdlint/parser/node'
require 'fdlint/parser/css/struct'

module FdlintTest
  module CSS
    module Rule
      
      class CheckListRuleTest < Test::Unit::TestCase

        Node = Fdlint::Parser::Node
        Fdlint::Rule.rules

        def setup
          @file = nil
        end

        # selector

        def test_check_selector_with_id

          # 路径中不包含 /lib/ 文件会被辨认为页面级别样式
          # 此时检查 selecotr id 的规则才会生效
          css_file_level :page

          parse :selector, '#mydiv a' do |results|
            assert_has_result results, [:error, '页面级别样式不使用id']
          end

          parse :selector, 'ul #mydiv dt' do |results|
            assert_has_result results, [:error, '页面级别样式不使用id']
          end

          parse :selector, '.guide-part ul li' do |results|
            assert results.blank?
          end
        end

        def test_check_selector_with_global_tag 
          # 路径中不包含 /lib/ 文件会被辨认为页面级别样式
          # 此时检查 global selecotr 的规则才会生效
          css_file_level :page

          parse :selector, 'a' do |results|
            assert_has_result results, [:error, '页面级别样式不能全局定义标签样式']
          end

          parse :selector, 'body' do |results|
            assert_has_result results, [:error, '页面级别样式不能全局定义标签样式']
          end
        end

        def test_check_selector_level
          parse :selector, '.mypart .mysubpart ul li a' do |results|
            assert_has_result results, [:error, 'CSS级联深度不能超过4层']
          end

          parse :selector, 'html>div.mypart ul li a' do |results|
            assert_has_result results, [:error, 'CSS级联深度不能超过4层']
          end

          parse :selector, '.mypart ul li a' do |results|
            assert results.blank?
          end

          parse :selector, 'div.mypart ul li a' do |results|
            assert results.blank?
          end
        end

        def test_check_selector_with_star
          parse :selector, '* html' do |results|
            assert_has_result results, [:error, '禁止使用星号选择符']
          end
        end

        # declaration
        
        def test_check_good_declaration_font
          parse :declaration, 'font: Arail;' do |results|
            assert results.blank?
          end
        end

        def test_check_declaration_font
          parse :declaration, 'font: 宋体;' do |results|
            assert_has_result results, [:error, '字体名称中的中文必须用ascii字符表示']
          end
        end

        def test_check_property_hack
          props = %w(_background +font-size *color d\isplay)
          props.each do |prop|
            parse :property, prop do |results|
              assert_has_result results, [:error, '合理使用hack']
            end
          end
        end

        def test_check_selector_using_hack
          parse :selector, 'html*' do |results|
            assert_has_result results, [:error, '合理使用hack']
          end
        end

        def test_check_value_use_css_expression
          parse :value, 'expression(onfocus=this.blur())' do |results|
            assert_has_result results, [:error, '禁止使用CSS表达式']
          end
        end

        def test_check_value_use_hack
          exprs = %w(9px\0 #000\9)
          exprs.each do |expr|
            parse :value, expr do |results|
              assert_has_result results, [:error, '合理使用hack']
            end
          end
        end

        private

          def css_file_level level
            if level == :page
              @file = File.new( '.' )
            elsif level == :lib
              @file = File.new( File.join FIXTURE_PATH, 'css/lib/' )
            end
          end

          def parse type, text
            parser   = Fdlint::Parser::CSS::CssParser.new( text ).tap do |parser|
              visitors = Fdlint::Rule.for_css_content.map do |validation|
                validation.to_visitor file: @file
              end
              parser.add_visitors visitors
              parser.send "parse_#{type}"
            end

            yield parser.results.flatten
          end

      end

    end
  end
end
