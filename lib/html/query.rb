require 'strscan'

module XRay
  module HTML
    
    class Element
      
      WORD = /[A-Za-z][-_\w]*/
      CLASS = %r(\.#{WORD})
      ID = %r(##{WORD})
      PROP_PAIR = %r(\s*,?\s*#{WORD}(==[^\s,])?)
      PROP = %r(\[#{WORD}.*?\])

      def query_obj(str)
        classes = []
        props = {}
        sc  = StringScanner.new(str)
        tag = sc.scan WORD
        if sc.check ID
          sc.skip /#/
          id  = sc.scan WORD
        end
        while sc.check CLASS
          sc.skip /\./
          classes << (sc.scan WORD)
        end
        if sc.check PROP
          sc.skip /\[/
          while sc.check PROP_PAIR
            sc.skip /\s*/
            sc.skip /,/
            sc.skip /\s*/
            prop = sc.scan WORD
            sc.skip /\==/
            sc.skip /['"]/
            value = sc.scan /[^\]]+/
            props[prop] = value
          end
          sc.skip /\]/
        end
        props["id"] = id if id
        {:tag => tag, :classes => classes, :properties => props }
      end

      def match(str)
        obj = query_obj(str)
        tag = obj[:tag]
        cls = obj[:classes]
        props = obj[:properties]
        unless tag.nil? or tag_name_equal? tag
          return false
        end
        classes = prop_value(:class)
        cls.each { |c| return false unless classes.include? c }
        props.each do |n, v|
          if v.nil?
            return false unless has_prop? n
          else
            return false unless prop_value(n) == v
          end
        end
        true
      end

      alias_method :===, :match

    end

  end
end
