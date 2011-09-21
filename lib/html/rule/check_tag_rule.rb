# encoding: utf-8
require_relative '../struct'

module XRay
  module HTML
    module Rule

      class CheckTagRule

        attr_reader :imported_scripts, :imported_css

        def initialize(opt=nil)
          @imported_scripts, @imported_css = [], []
        end

        def visit_tag(tag)
          check_tag(tag)
        end

        def visit_property(prop)
          check_prop(prop)
        end

        def check_tag(tag)
          check [
            :check_tag_name_downcase,
            :check_unique_script_import,
            :check_unique_style_import,
            :check_img_must_have_alt,
            :check_hyperlink_with_target,
            :check_hyperlink_with_title
          ], tag
        end

        def check_tag_name_downcase(tag)
          if tag.tag_name =~ /[A-Z]/
            ["标签名必须小写", :warn]
          end
        end

        def check_img_must_have_alt(tag)
          if tag.tag_name_equal? 'img'
            unless tag.has_prop?(:alt)
              ["img标签必须加上alt属性", :warn]
            end
          end
        end

        def check_hyperlink_with_target(tag)
          if tag.tag_name_equal? 'a' and tag.prop_value(:href)[0] == '#' and tag.prop_value(:target) != '_self'
            ['功能a必须加target="_self"，除非preventDefault过', :info]
          end
        end

        def check_hyperlink_with_title(tag)
          if tag.tag_name_equal? 'a' and tag.prop_value(:href)[0] != '#' 
            unless (prop = tag.prop_value(:title)) and !prop.empty?
              ['非功能能点的a标签必须加上title属性', :warn]
            end
          end
        end

        def check_unique_script_import(tag)
          if tag.tag_name_equal? 'script'
            src = tag.prop_value(:src).to_s
            if @imported_scripts.include? src
              ["避免重复引用同一或相同功能文件", :warn]
            else
              @imported_scripts << src
              nil
            end
          end
        end

        def check_unique_style_import(tag)
          if tag.tag_name_equal? 'link' and tag.prop_value(:rel) =~ /stylesheet/i
            src = tag.prop_value(:href).to_s
            if @imported_css.include? src
              ["避免重复引用同一或相同功能文件", :warn]
            else
              @imported_css << src
              nil
            end
          end
        end

        # PROPERTY

        def check_prop(prop)
          check [
            :check_inline_style_prop,
            :check_prop_name_downcase
          ], prop
        end

        def check_inline_style_prop(prop)
          if prop.name =~ /^style$/im
            ["不能定义内嵌样式style", :warn]
          end
        end

        def check_prop_name_downcase(prop)
          if prop.name =~ /[A-Z]/
            ["属性名必须小写，连字符用中横线", :warn]
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
