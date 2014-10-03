module Fdlint::Parser

  Position = Struct.new(:pos, :row, :column)
  class Position
    def to_s
        "[#{row},#{column}]"
    end

    def inspect
      "[#{pos}, #{row}:#{column}]"
    end

    def to_position
      self
    end
  end

  class BytePosition < Struct.new(:text, :pos)

    def row
      to_position.row
    end

    def column
      to_position.column
    end

    def to_position
      @position ||= PositionInfo.new(text).locate(charpos)
    end

    private

      def charpos
        scanner = StringScanner.new(text)
        scanner.pos = pos
        return scanner.charpos
      end
    
  end

  class PositionInfo

    attr_accessor :text
  
    def initialize(text)
      @text = text.freeze
      lines = text.split(/\n/)

      @lines = []
      num = 0
      lines.each do |line|
        num += line.length + 1
        @lines << num
      end

      @len = lines.length
    end

    # Public: Turn given number position index into a
    #         position object which contains the 
    #         column and row index info
    #
    # pos - position index of the source string
    #
    # Returns the position object
    def locate(pos)
      if @row && pos >= @lines[@row -1] && pos < @lines[@row]
        row = @row
      else
        row = @row = find(0, @len - 1, pos)
      end
      col = row > 0 ? pos - @lines[row - 1] : pos
      Position.new(pos, row + 1, col + 1)
    end

    def locate_with_bytepos( bytepos )
      BytePosition.new( text, bytepos )
    end

    private

      def find(low, high, pos)
        return low unless low < high

        mid = (low + high) / 2
        pos < @lines[mid] ? find(low, mid, pos) :
          find(mid + 1, high, pos)
      end



  end
end
