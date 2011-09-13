require_relative '../base_parser'
require_relative 'struct'

module XRay; module HTML

  class Parser < BaseParser

    R_TEXT = /[^<]+/
    PROP_REG = /(\w+)\s*=\s*"(\w+)"/
    R_TAG = /<[\w\/].*>/

    def parse
      nodes = batch(:parse_element)
      nodes[0]
    end

    def parse_element
      if @scanner.check(R_TAG)
        children = []
        skip /</
        tag = @scanner.scan(/\w+/)
        prop = parse_properties
        @scanner.skip_until />/
        inner = @scanner.check /[^<]+/
        children << parse_element if inner
        @scanner.skip_until />/
        Element.new(tag, prop, children)
      else
        text = @scanner.scan(R_TEXT)
        TextElement.new(text)
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
      if @scanner.check PROP_REG
        @scanner.scan(PROP_REG) 
        { :"#{@scanner[1]}" => @scanner[2] }
      end
    end

  end


  def self.parse(src, &block)
    parser = Parser.new(src)
    doc = parser.parse
    yield doc if block 
  end

end; end
