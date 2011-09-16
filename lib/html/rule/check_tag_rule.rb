# encoding: utf-8
require_relative '../struct'

module XRay
  module HTML
    module Rule

      class CheckTagRule

        def check_prop(prop)
          check [
            :check_inline_style_prop
          ], prop
        end

        def check_inline_style_prop(prop)
          if prop.name =~ /^style$/
            ["不能定义内嵌样式style", :warn]
          end
        end

        private
        def check(items, node)
          results = []
          items.each do |item|
            result = self.send(item, node)
            result && (results << result.flatten)
          end
          results
        end


      end

    end
  end
end
