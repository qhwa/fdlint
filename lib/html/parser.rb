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

    TEXT = /([^<]|(<[^\w\/]))+/
    PROP = /(?<name>\w+)\s*(?:=\s*(?<sep>['"]?)(?<value>\w+)\k<sep>)?/ #require Ruby 1.9
    TAG_NAME = /[\w\/][^>\s]*/
    TAG = %r(<(#{TAG_NAME})(\s+#{PROP})*\s*>)
    SELF_CLOSE_TAG = %r(<#{TAG_NAME}(\s+#{PROP})*\s+\/>)

    def parse
      nodes = batch(:parse_element)
      case nodes.size
        when 0 then nil
        when 1 then nodes[0]
        else nodes
      end
    end

    def parse_element
      if @scanner.check(TAG)
        parse_normal_tag
      elsif @scanner.check(SELF_CLOSE_TAG)
        parse_self_closing_tag
      else
        parse_text
      end
    end

    def parse_properties
      skip_empty
      props = {}
      until prop_search_done? do
        prop = parse_property
        props.merge! prop if prop
        skip_empty
      end
      props
    end

    def prop_search_done?
      @scanner.check(/\/>|>/) or @scanner.eos?
    end

    def parse_property
      scan(PROP) 
      #TODO: return Node
      { :"#{@scanner[1]}" => @scanner[3] }
    end

    protected
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

    def parse_text
      text = @scanner.scan(TEXT)
      TextElement.new(text)
    end

    def auto_close?(tag)
      XRay::HTML::AUTO_CLOSE_TAGS.include?(tag.to_s)
    end

  end


end; end

if __FILE__ == $0
  XRay::HTML::Parser.parse(%q(<div class="info" checked>information</div>)) { |e| puts e.outer_html }
  XRay::HTML::Parser.parse(%q(<img width="100" height="150" > text)) { |e| puts e.first.outer_html }
end
