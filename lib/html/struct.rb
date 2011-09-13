require_relative '../node'

module XRay
  module HTML

    Node = XRay::Node

    class Element < Node

      attr_reader :tag, :props, :children

      def initialize(tag, props={}, children=[])
        @tag, @prop, @children = tag, props || {}, children || []
      end

      def text
        children.inject("") do |s,child|
          s + child.text
        end
      end

      def inner_html
        @children.inject('') { |s,c| s + c.outer_html }
      end

      def outer_html
        props = to_param_string(@prop)
        if children.empty?
          "<#{@tag}#{props} />"
        else
          "<#{@tag}#{props}>#{inner_html}</#{@tag}>"
        end
      end

      def inner_text
        @children.inject('') { |s,c| s + c.inner_text }
      end

      def ==(other)
        @tag == other.tag && @props == other.props && inner_html == other.inner_html
      end

      protected
      def parse(text)
        @outer_html = text
      end

      private
      def to_param_string( hash )
        hash.inject('') do |s, p|
          s + " #{p.join('="')}\""
        end
      end

    end


    class TextElement < Element

      def initialize(text="")
        super(nil)
        @text = text
      end

      def text; @text; end

      alias_method :inner_text, :text
      alias_method :inner_html, :text
      alias_method :outer_html, :text

    end


    class CommentElement < Element
      def children
        nil
      end
    end


    class Property < Node
      
    end


  end
end

if $0 == __FILE__
  Element = XRay::HTML::Element
  TextElement = XRay::HTML::TextElement
  puts TextElement.new('hello').inner_text
  puts TextElement.new('hello').inner_text
  puts Element.new('div', {:class => 'info'}).outer_html
end
