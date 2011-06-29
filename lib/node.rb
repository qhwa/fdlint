module XRay

  class Node

    attr_reader :text
    attr_reader :position

    def initialize(text = '', position = nil)
      @text, @position = text, position
    end

    def to_s
      text
    end
  end

end
