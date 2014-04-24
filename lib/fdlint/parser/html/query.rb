require 'strscan'

module Fdlint; module Parser; module HTML
    
  module Query
    
    WORD      = /[A-Za-z][-_\w]*/
    CLASS     = %r(\.#{WORD})
    ID        = %r(##{WORD})
    PROP_PAIR = %r(\s*,?\s*#{WORD}(==[^\s,])?)
    PROP      = %r(\[#{WORD}.*?\])

    ###
    # This method implemented CSS selector for
    # HTML (like Sizzle) very simply. It is not
    # fully supported CSS selector.
    #
    # TODO: support full CSS3 selector
    ###
    def match?(str)
      query       = query_obj(str)
      tag_query   = query[:tag]
      class_query = query[:classes]
      prop_query  = query[:properties]

      (tag_query.blank?   || match_tag?( tag_query )) &&
      (class_query.blank? || match_class?( class_query )) &&
      (prop_query.blank?  || match_prop?( prop_query ))
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

      def match_tag?( tag_query )
        tag_name_equal? tag_query
      end

      def match_class?( class_query )
        classes = prop_value(:class)
        if classes.blank?
          false
        else
          class_query.all? do |c|
            classes.include? c
          end
        end
      end

      def match_prop?( prop_query )
        prop_query.all? do |n, v|
          if v.nil?
            has_prop? n
          else
            prop_value(n) == v
          end
        end
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

end; end; end
