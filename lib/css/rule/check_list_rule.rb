# encoding: utf-8

require_relative '../../rule_helper'

module XRay
  module CSS
    module Rule

      class CheckListRule
        
        include RuleHelper
        
        def initialize(options = {}) 
          @options = options
        end

        # selector

        def visit_simple_selector(selector)
          dispatch([
            :check_selector_with_id,
            :check_selector_with_global_tag,
            :check_selector_level,
            :check_selector_with_star,
            :check_selector_redefine_lib_css
          ], selector) 
        end
        
        def check_selector_with_id(selector)
          if @options[:scope] != 'lib' &&
              selector =~ /#[-\w]+/
            ['页面级别样式不使用id', :error]
          end
        end

        def check_selector_with_global_tag(selector)
          if @options[:scope] != 'lib' &&
              selector =~ /^\w+$/
            ['页面级别样式不能全局定义标签样式', :error]
          end
        end

        def check_selector_level(selector)
          parts = selector.text.split /[>\s]/
          if parts.length > 4
            ['CSS级联深度不能超过4层', :error]
          end
        end

        def check_selector_with_star(selector)
          if selector =~ /^\*/
            ['禁止使用星号选择符', :error]
          end
        end

        def check_selector_redefine_lib_css(selector)
          if @options[:scope] != 'lib' &&
              selector =~ /^\.fd-\w+$/
            ['禁止修改或重载type中的样式', :error]
          end
        end

        # declaration
        def visit_declaration(dec)
          dispatch([
            :check_declaration_font
          ], dec)
        end

        def check_declaration_font(dec)
          if dec.property =~ /^font(-family)?$/ && 
              dec.value.to_s.each_byte.any? {|b| b>127}
            ['字体名称中的中文必须用ascii字符表示', :error]
          end
        end

        # ruleset
        
        def visit_ruleset(ruleset)
          dispatch([
            :check_ruleset_redefine_a_hover_color,
            #:check_declarations_sequence
          ], ruleset);
        end

        def check_ruleset_redefine_a_hover_color(ruleset)
          if ruleset.selector.text == 'a:hover' &&
              ruleset.declarations.find { |dec| dec.property.text == 'color' }
            ['禁止重写reset中定义的a标签的hover色（现为#ff7300）', :error]
          end
        end

        def check_declarations_sequence(ruleset)
          list = [
            %w(position display visible z-index overflow float clear),
            %w(width height top right bottom left margin padding border),
            %w(background opacity),
            %w(font color text line-height vertical-align)
          ] 

          now = 0
          ruleset.declarations.each do |dec|
            prop_text = dec.property.text
            index = list.find_index do |bag| 
              bag.any? { |field| prop_text.index field }
            end 

            next unless index
            return ['建议使用Mozilla推荐CSS书写顺序'\
                'http://wd.alibaba-inc.com/doc/page/regulations/css', :warn] if index < now
            now = index
          end
          nil
        end

        # property
        def visit_property(property)
          dispatch([
            :check_property_hack
          ], property)
        end

        def check_property_hack(property)
          if property =~ /[^-a-z]/
            ['合理使用hack', :error]
          end
        end

        # value

        def visit_value(value)
          dispatch([
            :check_value_use_css_expression,
            :check_value_use_hack
          ], value);
        end

        def check_value_use_css_expression(value)
          if value =~ /^expression\(/
            ['禁止使用CSS表达式', :error]
          end
        end

        def check_value_use_hack(value)
          if value =~ /\\\d$/
            ['合理使用hack', :error]
          end
        end

      end

    end
  end
end
