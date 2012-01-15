# encoding: utf-8

require_relative '../../helper'

require 'node'
require 'css/struct'
require 'css/rule/check_list_rule'

module XRayTest
  module CSS
    module Rule
      
      class CheckListRuleTest < Test::Unit::TestCase

        include XRay::CSS, XRay::CSS::Rule, XRay::Rule

        XRay::Rule.import_all
       
        Node = XRay::Node

        def setup
        end

        # selector

        def test_check_selector_with_id
          selector = Node.new '#mydiv a'
          message, level = check_selector_with_id selector

          assert_equal :error, level

          selector = Node.new 'ul #mydiv dt'
          ret = check_selector_with_id selector
          assert_not_nil ret

          selector = Node.new '.guide-part ul li'
          ret = check_selector_with_id selector
          assert_nil ret
        end

        def test_check_selector_with_global_tag 
          selector = Node.new 'a'
          message, level = check_selector_with_global_tag selector

          assert_equal :error, level

          selector = Node.new 'body'
          message, level = check_selector_with_global_tag selector

          assert_equal :error, level
        end

        def test_check_selector_level
          selector = Node.new '.mypart .mysubpart ul li a'
          message, level = check_selector_level selector

          assert_equal :error, level
          
          selector = Node.new '.mypart ul li a'
          ret = check_selector_level selector
          assert_nil ret
          
          selector = Node.new 'html>div.mypart ul li a'
          message, level = check_selector_level selector
          assert_equal :error, level

          selector = Node.new 'div.mypart ul li a'
          ret = check_selector_level selector
          assert_nil ret
        end

        def test_check_selector_with_star
          selector = Node.new '* html'
          message, level = check_selector_with_star selector

          assert_equal :error, level
        end

        def test_check_declarations_sequence
          
        end

        # declaration
        
        def test_check_good_declaration_font
          sel = Node.new 'font'
          expr = Node.new 'Arial'
          dec = Declaration.new(sel, expr)

          message, level = check_declaration_font dec
          assert_equal nil, level
        end

        def test_check_declaration_font
          sel = Node.new 'font'
          expr = Node.new '宋体'
          dec = Declaration.new(sel, expr)

          message, level = check_declaration_font dec
          assert_equal :error, level
        end

        def test_check_redefine_a_hover_color
          selector = Node.new 'a:hover'
          
          prop = Node.new 'color'
          expr = Node.new '#f00'
          dec = Declaration.new(prop, expr)

          ruleset = RuleSet.new(selector, [dec])

          message, level = check_ruleset_redefine_a_hover_color ruleset
          assert_equal :error, level
        end

        def test_check_redefine_lib_css
          selector = Node.new '.fd-hide'
          message, level = check_selector_redefine_lib_css selector
          assert_equal :error, level

          selector.context.scope = :lib
          ret = check_selector_redefine_lib_css selector
          assert_nil ret 
        end
        
        def test_check_property_hack
          props = %w(_background +font-size *color)
          props.each do |prop|
            prop = Node.new prop
            message, level = check_property_hack prop
            assert_equal :error, level
          end
        end

        def test_check_value_use_css_expression
          expr = Node.new 'expression(onfocus=this.blur())'
          message, level = check_value_use_css_expression expr
          assert_equal :error, level
        end

        def test_check_value_use_hack
          exprs = %w(9px\0 #000\9)
          exprs.each do |expr|
            expr = Node.new expr
            message, level = check_value_use_hack expr
            assert_equal :error, level
          end
        end

      end

    end
  end
end
