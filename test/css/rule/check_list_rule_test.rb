# encoding: utf-8

require_relative '../../helper'

require 'node'
require 'css/struct'
require 'css/rule/check_list_rule'

module XRayTest
  module CSS
    module Rule
      
      class CheckListRuleTest < Test::Unit::TestCase
        include XRay::CSS, XRay::CSS::Rule
       
        Node = XRay::Node

        def setup
          @rule = CheckListRule.new :scope => 'page'
        end

        # selector

        def test_check_selector_with_id
          selector = Node.new '#mydiv a'
          message, level = @rule.check_selector_with_id selector

          assert_equal :warn, level
          puts message

          selector = Node.new 'ul #mydiv dt'
          ret = @rule.check_selector_with_id selector
          assert_not_nil ret

          selector = Node.new '.guide-part ul li'
          ret = @rule.check_selector_with_id selector
          assert_nil ret
        end

        def test_check_selector_with_global_tag 
          selector = Node.new 'a'
          message, level = @rule.check_selector_with_global_tag selector

          assert_equal :error, level
          puts message

          selector = Node.new 'body'
          message, level = @rule.check_selector_with_global_tag selector

          assert_equal :error, level
        end

        def test_check_selector_level
          selector = Node.new '.mypart .mysubpart ul li a'
          message, level = @rule.check_selector_level selector

          assert_equal :warn, level
          puts message
          
          selector = Node.new '.mypart ul li a'
          ret = @rule.check_selector_level selector
          assert_nil ret
          
          selector = Node.new 'html>div.mypart ul li a'
          message, level = @rule.check_selector_level selector
          assert_equal :warn, level

          selector = Node.new 'div.mypart ul li a'
          ret = @rule.check_selector_level selector
          assert_nil ret
        end

        def test_check_selector_with_star
          selector = Node.new '* html'
          message, level = @rule.check_selector_with_star selector

          assert_equal :fatal, level
          puts message
        end

        # declaration
        
        def test_check_declaration_hack
          decs = ['_background: none', '+font-size: 12px', '*color: #ff0000', 
              'font-size: 12px\9', 'font-weight:' 'bold\0']

          decs.each do |dec|
            puts dec

            dec = Node.new dec
            message, level = @rule.check_declaration_hack dec
            assert_equal :warn, level
          end
        end

        def test_check_declaration_font
          sel = Node.new 'font'
          expr = Node.new '宋体'
          dec = Declaration.new(sel, expr)

          message, level = @rule.check_declaration_font dec
          assert_equal :error, level
          puts message
        end

        def test_check_redefine_a_hover_color
          selector = Node.new 'a:hover'
          
          prop = Node.new 'color'
          expr = Node.new '#f00'
          dec = Declaration.new(prop, expr)

          ruleset = RuleSet.new(selector, [dec])

          message, level = @rule.check_ruleset_redefine_a_hover_color ruleset
          assert_equal :error, level
          puts message
        end

        def test_check_redefine_lib_css
          selector = Node.new '.fd-hide'
          message, level = @rule.check_selector_redefine_lib_css selector
          assert_equal :error, level
          puts message

          rule = CheckListRule.new :scope => 'lib'
          ret = rule.check_selector_redefine_lib_css selector
          assert_nil ret 
        end
        
        def test_check_css_expression
          expr = Node.new 'expression(onfocus=this.blur())'
          message, level = @rule.check_expression_use_css_expression expr
          assert_equal :error, level
          puts message
        end

      end

    end
  end
end
