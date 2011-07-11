# encoding: utf-8

module XRay
  module CSS
    module Rule

      class CheckFileRule
        
        def initialize(options = {}) 
          @options = options
        end

        # selector

        def validate(file)
          check([
            :check_name_without_ad,
            :check_encoding,
          ], file) 
        end
        
        def check_encoding(file)
          ['ecoding must be gb2312', :warn]
        end

        private
        
        def check(items, file)
          results = []
          items.each do |item|
            result = self.send(item, file)
            result && (results << result)
          end
          results
        end

      end

    end
  end
end
