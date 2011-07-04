# encoding: utf-8

module XRay
  module CSS
    module Rule

      class CheckListRule
        
        def initialize(options = {}) 
          @options = options
        end

        # selector

        def visit_simple_selector(selector)
          check([
            :check_selector_with_id,
            :check_selector_with_global_tag,
            :check_selector_level,
            :check_selector_with_star
          ], selector) 
        end
        
        def check_selector_with_id(selector)
          if @options[:scope] == 'page' &&
              selector =~ /#[-\w]+/
            ['页面级别样式不使用id', :warn]
          end
        end

        def check_selector_with_global_tag(selector)
          if @options[:scope] == 'page' &&
              selector =~ /^\w+$/
            ['页面级别样式不能全局定义标签样式', :error]
          end
        end

        def check_selector_level(selector)
          parts = selector.text.split /[>\s]/
          if parts.length > 4
            ['CSS级联深度不能超过4层', :warn]
          end
        end

        def check_selector_with_star(selector)
          if selector =~ /^\*/
            ['禁止使用星号选择符', :fatal]
          end
        end


        # declaration
        def visit_declaration(dec)
          check([
            :check_declaration_hack,
            :check_declaration_font
          ], dec)
        end

        def check_declaration_hack(dec)
          if dec =~ /^[_*+]|[\\9\\0]$/
            ['合理使用hack', :warn]
          end
        end

        def check_declaration_font(dec)
          if dec.property =~ /^font/ && 
              dec.expression =~ /[\u4e00-\u9fa5]/
            ['字体名称中的中文必须用ascii字符表示', :error]
          end
        end

        private
        
        def check(items, node)
          items.inject([]) do |results, item|
            result = self.send(item, node)
            result && (results << result)
          end
        end

      end

    end
  end
end
