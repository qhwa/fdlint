module Fdlint; module Parser
  module HTML

    Node = ::Fdlint::Parser::Node

    AUTO_CLOSE_TAGS = %w(area base basefont br col frame hr img input link meta param) 
    INLINE_ELEMENTS = %w(a br label abbr legend address link 
                         area mark audio meter bm nav cite optgroup 
                         code option del q details small dfn select 
                         command source datalist span em strong 
                         font sub i summary iframe sup img tbody 
                         input td ins time kbd var)

    class Element < Node

      attr_reader :tag, :props, :children
      attr_accessor :parent, :close_type, :ending, :scopes

      def initialize(tag, props=[], children=[], close_type=:after, ending=nil)
        @tag, @props, @children, @close_type, @ending = tag, to_props(props), Array.[](children).flatten || [], close_type, ending
        @position = @tag.position.dup if tag.is_a?(Node) and tag.position
        @children.each { |el| el.parent = self }
        @scopes = []
      end

      def has_scope?
        !(parent.nil? and @scopes.empty?)
      end

      def in_scope?(scp)
        if parent
          parent.tag_name_equal? scp
        else
          scopes.include?(scp)
        end
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
          cls = ending || "</#{@tag}>"
          "<#{@tag}#{prop_text}>#{inner_html}#{cls}"
        end
      end

      def inner_text
        @children.inject('') { |s,c| s + c.inner_text }
      end

      alias_method :text, :inner_text

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

      def inline?
        INLINE_ELEMENTS.include? tag_name.downcase
      end

      def auto_close?
        AUTO_CLOSE_TAGS.include? tag_name.downcase
      end

      def closed?
        @close_type != :none
      end

      def self_closed?
        @close_type == :self
      end

      def each(&block)
        children.each {|node| yield node }
      end

      def empty?
        false
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


    class Document < Element
      def initialize( children=[] )
        super(nil, {}, children || [])
        @position = Position.new(0,0,0)
      end

      def ==(other)
        if other.is_a?(Array)
          return children == other
        elsif other.is_a?(Document)
          return children == other.children
        else
          super
        end
      end

      def empty?
        children.empty?
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

      def tag_name_equal?(name); false; end
      def inline?; true; end
      def auto_close? ; false; end
      def closed? ; true; end

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

      def tag_name_equal?(name); false; end
      def inline? ; true; end
      def auto_close? ; false; end
      def closed? ; true; end

      def to_s
        "[Comment: #{text}]"
      end

    end

    class DTDElement < Element

      attr_accessor :type

      def initialize(type, pre="DOCTYPE", pos=nil)
        @type, @pre = type, pre
        @position   = pos || Position.new(0,0,0)
      end

      def to_s
        "<!#{@pre} #{type}>"
      end

      def inline?
        true
      end

      alias_method :outer_html, :to_s

      def ==(other)
        other.is_a?(DTDElement) and other.type == type
      end

      def =~(other)
        to_s =~ other
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
end; end
