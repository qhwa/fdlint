require_relative '../base_parser'
require_relative 'struct'

module XRay; module HTML

  class Parser < BaseParser

    TEXT = /[^<]+/
    PROP = /(\w+)\s*=\s*"(\w+)"/
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
      if @scanner.check PROP
        scan(PROP) 
        #TODO: return with Node
        { :"#{@scanner[1]}" => @scanner[2] }
      end
    end

    protected
    def parse_normal_tag
      skip /</
      tag, prop = scan(TAG_NAME), parse_properties
      skip />/
      children = parse_element
      skip %r(<\/#{tag.text}>) 
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

  end


  def self.parse(src, &block)
    parser = Parser.new(src)
    doc = parser.parse
    yield doc if block_given? 
    doc
  end

end; end
