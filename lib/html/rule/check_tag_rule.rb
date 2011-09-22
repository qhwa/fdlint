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

        def visit_html(html)
          ["必须存在文档类型声明", :warn] unless @have_dtd
        end

        def visit_dtd(dtd)
          @have_dtd = true
          check_dtd(dtd)
        end

        def visit_tag(tag)
          check_tag(tag)
        end

        def visit_property(prop)
          check_prop(prop)
        end

        def check_dtd(dtd)
          check [
            :check_dtd_type_be_html5
          ], dtd
        end

        def check_dtd_type_be_html5(dtd)
          unless dtd.type.downcase == 'html'
            ['新页面统一使用HTML 5 DTD', :info]
          end
        end

        def check_tag(tag)
          check [
            :check_tag_name_downcase,
            :check_unique_script_import,
            :check_unique_style_import,
            :check_img_must_have_alt,
            :check_hyperlink_with_target,
            :check_hyperlink_with_title,
            :check_no_import_in_style_tag
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
          if tag.tag_name_equal? 'a' and tag.prop_value(:href) =~ /^#/ and tag.prop_value(:target) != '_self'
            ['功能a必须加target="_self"，除非preventDefault过', :info]
          end
        end

        def check_hyperlink_with_title(tag)
          if tag.tag_name_equal? 'a' and tag.prop_value(:href) =~ /^[^#]/
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

        def check_no_import_in_style_tag(tag)
          if tag.tag_name_equal? 'style' and tag.inner_text =~ /@import\s/m
            ["不通过@import在页面上引入CSS", :warn]
          end
        end

        # PROPERTY

        def check_prop(prop)
          check [
            :check_inline_style_prop,
            :check_prop_name_downcase,
            :check_id_prop_value_downcase,
            :check_class_prop_value_downcase,
            :check_prop_value_sep,
            :check_prop_value_exsit
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

        def check_id_prop_value_downcase(prop)
          if prop.name_equal? 'id' and prop.value =~ /[A-Z]/
            ["id名称全部小写，单词分隔使用中横线", :warn]
          end
        end

        def check_class_prop_value_downcase(prop)
          if prop.name_equal? 'class' and prop.value =~ /[A-Z]/
            ["class名称全部小写，单词分隔使用中横线", :warn]
          end
        end

        def check_prop_value_sep(prop)
          if prop.value and prop.sep != '"'
            ["属性值必须使用双引号", :warn]
          end
        end

        def check_prop_value_exsit(prop)
          if prop.value.nil?
            ["不能仅有属性名", :warn]
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
