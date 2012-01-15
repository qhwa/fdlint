# encoding: utf-8
require_relative '../../rule'
require_relative '../struct'
require_relative '../query'

module XRay
  module HTML
    module Rule

      class CheckTagRule

        include ::XRay::Rule

        attr_reader :imported_scripts, :imported_css

        def initialize(opt=nil)
          @imported_scripts, @imported_css = [], []
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
          puts "------ checking tag"
          check_html_tag tag
        end

        def visit_property(prop)
          check_html_property prop
        end


        # PROPERTY



      end

    end
  end
end
