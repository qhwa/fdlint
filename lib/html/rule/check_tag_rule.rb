# encoding: utf-8
require_relative '../../rule'
require_relative '../struct'
require_relative '../query'
require_relative '../../context'

module XRay
  module HTML
    module Rule

      class CheckTagRule

        include ::XRay::Rule, Context

        attr_reader :imported_scripts, :imported_css

        def initialize(opt=nil)
          @imported_scripts, @imported_css = [], []
        end

        def script_used?( src )
          @imported_scripts.include? src
        end

        def style_used?( src )
          @imported_css.include? src
        end

        def visit_html(html)
          ["必须存在文档类型声明", :error] unless @have_dtd
          #check_html_doc html
        end

        def visit_dtd(dtd)
          @have_dtd = true
          check_html_dtd dtd
        end

        def visit_tag(tag)
          results = check_html_tag tag
          record_script(tag) or record_style(tag)
          results
        end

        def visit_property(prop)
          check_html_property prop
        end

        def record_script( tag )
          if tag.tag_name_equal? 'script'
            src = tag.prop_value(:src).to_s
            unless src.empty? or script_used? src
              @imported_scripts << src
            end
          end
        end

        def record_style( tag )
          if tag.tag_name_equal? 'link' and tag.prop_value(:rel) =~ /stylesheet/i
            src = tag.prop_value(:href).to_s
            unless src.empty? or style_used? src
              @imported_css << src
            end
          end
        end

      end

    end
  end
end
