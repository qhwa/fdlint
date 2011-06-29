module XRay
  
  class ParseError < RuntimeError
    attr_reader :position

    def initialize(msg = nil, position = nil)
      super
      @position = position
    end

    def to_s
      "#{message}#{@position}"
    end

  end
  
end
