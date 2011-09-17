require_relative '../base_parser'
require_relative 'struct'

module XRay; module HTML

  AUTO_CLOSE_TAGS = %w(area base basefont br col frame hr img input link meta param)

  class Parser < BaseParser

    def self.parse(src, &block)
      parser = self.new(src)
      doc = parser.parse
      yield doc if block_given? 
      doc
    end

    TEXT = /([^<]|(<[^\w\/]))+/m
    PROP_NAME = %r/\w[\w-]*/m
    PROP_VALUE = %r/'([^']*)'|"([^"]*)"|(\w+)/m
    PROP = %r/#{PROP_NAME}\s*(?:=\s*#{PROP_VALUE})?/m
    TAG_NAME = /[\w\/][^>\s]*/m
    TAG_START = %r/<(#{TAG_NAME})/
    TAG = %r/#{TAG_START}(\s+#{PROP})*\s*>/m
    SELF_CLOSE_TAG = %r/#{TAG_START}(\s+#{PROP})*\s+\/>/m

    def parse_html
      nodes = batch(:parse_element)
      case nodes.size
        when 0 then nil
        when 1 then nodes[0]
        else nodes
      end
    end

    alias_method :parse, :parse_html

    def parse_element
      if @scanner.check(TAG_START)
        parse_tag
      else
        parse_text
      end
    end

    def parse_text
      TextElement.new @scanner.scan(TEXT)
    end

    def parse_tag
      if @scanner.check TAG
        parse_normal_tag
      elsif @scanner.check SELF_CLOSE_TAG
        parse_self_closing_tag
      end
    end

    def parse_properties
      skip_empty
      props = []
      until prop_search_done? do
        prop = parse_property
        props << prop if prop
        skip_empty
      end
      props
    end

    def parse_property
      name = parse_prop_name
      if @scanner.check( /\s*=/ )
        skip /[=]/
        sep = @scanner.check(/['"]/)
        value = parse_prop_value
      end
      Property.new name, value, sep
    end

    def parse_prop_name
      scan PROP_NAME
    end

    def parse_prop_value
      scan PROP_VALUE
      Node.new("#{@scanner[1]}#{@scanner[2]}#{@scanner[3]}")
    end

    protected
    def prop_search_done?
      @scanner.check(/\/>|>/) or @scanner.eos?
    end

    def parse_normal_tag
      skip /</
      tag, prop = scan(TAG_NAME), parse_properties
      skip />/

      children = []
      if auto_close?(tag.text)
        #TODO: give a warning for this
      else
        end_tag = %r(<\/#{tag.text}>)
        until @scanner.check(end_tag) or @scanner.eos? do
          children << parse_element
        end
        skip end_tag
      end
      Element.new(tag, prop, children)
    end

    def parse_self_closing_tag
      skip /</
      tag = scan(TAG_NAME)
      prop = parse_properties
      skip /\/>/
      Element.new(tag, prop)
    end


    def auto_close?(tag)
      XRay::HTML::AUTO_CLOSE_TAGS.include?(tag.to_s)
    end

  end


end; end

if __FILE__ == $0
  XRay::HTML::Parser.parse(%q(<div class="info" checked>information</div>)) { |e| puts e.outer_html }
  XRay::HTML::Parser.parse(%q(<img width="100" height='150' id=img > text)) { |e| puts e.first.outer_html }
end
