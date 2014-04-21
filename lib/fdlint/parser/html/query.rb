require 'strscan'

module XRay
  module HTML
    
    class Element
      
      WORD = /[A-Za-z][-_\w]*/
      CLASS = %r(\.#{WORD})
      ID = %r(##{WORD})
      PROP_PAIR = %r(\s*,?\s*#{WORD}(==[^\s,])?)
      PROP = %r(\[#{WORD}.*?\])

      ###
      # This method implemented CSS selector for
      # HTML (like Sizzle) very simply. It is not
      # fully supported CSS selector.
      #
      # TODO: support full CSS3 selector
      ###
      def match?(str)
        return false if is_a?(TextElement)
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

      alias_method :===, :match?

      private
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

      public
      def query( selector, &block )
        ret = []
        if match?(selector)
          ret << self 
          yield self if block_given?
        end

        children && children.each do |node|
          ret += node.query(selector, &block)
        end

        ret
      end
      
      alias_method :*, :query

    end

  end
end
