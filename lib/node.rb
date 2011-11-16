module XRay

  class Node

    attr_accessor :text, :position

    def initialize(text = '', position = nil)
      if text.is_a? Node
        @text, @position = text.text, text.position
      else
        @text, @position = (text || '').strip, position
      end
    end

    def =~(other)
      text =~ other
    end

    def to_s
      text
    end

  end

end
