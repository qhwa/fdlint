module XRay
  module CSS
    module Rule

      class DefaultRule
      
        def visit_selector(selector)
          if selector.text.index('*') == 0
            ['it is a fatal error using star selector in page level css', :fatal]
          end
        end

      end

    end
  end
end
