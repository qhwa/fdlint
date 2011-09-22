require_relative '../node'

module XRay
  module HTML

    Node = XRay::Node

    class Element < Node

      attr_reader :tag, :props, :children

      def initialize(tag, props=[], children=[])
        @tag, @props, @children = tag, to_props(props), Array.[](children).flatten || []
        @position = @tag.position.dup if tag.is_a? Node
      end

      def text
        children.inject("") do |s,child|
          s + child.text
        end
      end

      def tag_name
        @tag.is_a?(Node) ? @tag.text : @tag.to_s
      end

      def tag_name_equal?(name)
        tag_name.downcase == name.downcase
      end

      def inner_html
        @children.inject('') { |s,c| s + c.outer_html }
      end

      def outer_html
        if children.empty?
          "<#{@tag}#{prop_text} />"
        else
          "<#{@tag}#{prop_text}>#{inner_html}</#{@tag}>"
        end
      end

      def inner_text
        @children.inject('') { |s,c| s + c.inner_text }
      end

      def prop_text
        props.inject('') { |s, p| s << " " << p.to_s }
      end

      def ==(other)
        other.is_a?(Element) and tag_name == tag_name.to_s && prop_text == other.prop_text && inner_html == other.inner_html
      end
      
      def has_prop?(name)
        @props.any? { |p| p.name_equal? name }
      end

      def prop(name)
        @props.find { |p| p.name_equal? name }
      end

      def prop_value(*arg)
        name, value = *arg
        if arg.size > 1
          unless @props.find { |p| p.value = value if p.name_equal? name }
            @props << Property.new(name, value) 
          end
          nil
        else
          p = prop(name)
          p.value if p
        end
      end

      def to_s
        "[HTML: #{outer_html}]"
      end

      protected
      def parse(text)
        @outer_html = text
      end

      private

      def to_props(src)
        case src
          when Array
            src
          when Hash
            src.map do |n, v|
              Property.new(n, v)
            end
          else
            []
          end
      end

    end


    class TextElement < Element

      def initialize(text="")
        super(nil)
        @text = text.to_s
      end

      def text; @text; end
      def tag_name; nil; end

      alias_method :inner_text, :text
      alias_method :inner_html, :text
      alias_method :outer_html, :text

      def ==(other)
        text == other.text
      end

      def tag_name_equal?(name)
        false
      end

      def to_s
        "[TEXT: #{text}]"
      end

    end


    class CommentElement < Element
      def initialize(text)
        super(nil)
        @text = text.to_s
      end

      def content; @text; end
      def tag_name; nil; end

      alias_method :inner_text, :text
      alias_method :inner_html, :text
      
      def outer_html
        "<!--#{text}-->"
      end

      def ==(other)
        text == other.text
      end

      def to_s
        "[Comment: #{text}]"
      end

    end

    class DTDElement < Element

      attr_accessor :type

      def initialize(type, pre="DOCTYPE", pos=nil)
        @type, @pre, @position = type, pre, pos || Position.new(0,0,0)
      end

      def to_s
        "<!#{@pre} #{type}>"
      end

      alias_method :outer_html, :to_s

      def ==(other)
        other.is_a?(DTDElement) and other.type == type
      end

    end

    class Property < Node

      attr_reader :name, :sep
      attr_accessor :value

      def initialize(name, value, sep='"')
        @name, @value, @sep = name, value, sep
      end

      def position; name.position; end

      def name_equal?(text)
        @name.to_s.downcase == text.to_s.downcase
      end

      def to_s
        if value.nil?
          name.to_s
        else
          "#{name}=#{sep}#{value}#{sep}"
        end
      end

    end


  end
end
