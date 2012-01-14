require_relative 'context'

module XRay

  class Node

    attr_accessor :text, :position, :context

    def initialize(text = '', position = nil)
      #TODO: use shared context for better performance
      # and set real context here
      @context = Context.new

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
