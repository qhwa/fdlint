# encoding: utf-8

require 'net/http'

module XRay
  module HTML
    module Rule
      
      class CheckLinkRule

          WRONG_PAGES = [/\bwrongpage\.html\b/]

          def initialize(opts = {})
            @options = opts
          end
        
          def visit_tag(tag)
            unless @options[:check_html_link]
              return
            end

            if tag.tag_name_equal? 'a'
              url = tag.prop_value(:href)
              unless /^https?:\/\// =~ url
                return ['无效的链接地址，需要以http[s]://带头', :error]
              end

              unless valid? url
                return ['无效的链接地址，不能正常访问', :error]
              end
            end
          end

          private

          def valid?(url)
            begin
              uri = URI(url)
              res = Net::HTTP.get_response(uri)
              code = res.code.to_i

              if code >= 400
                return false
              end

              if code >= 300
                loc = res['Location']
                if loc and WRONG_PAGES.any? { |page| page =~ loc }
                  return false
                end
              end
            rescue
              return false
            end

            true
          end

      end

    end
  end
end

