module XRay

  Position = Struct.new(:pos, :row, :column)
  class Position
    def to_s
        "[#{row + 1},#{column + 1}]"
    end
  end

  class PositionInfo
  
    def initialize(text)
      lines = text.split(/\n/)
      @lines_info = lines.map &:bytesize
    end

    def locate(pos)
      row = 0
      col = pos
      now = @lines_info[row]
      
      while now && col > now
        col -= (now + 1)
        row += 1
        now = @lines_info[row]
      end

      now ? Position.new(pos, row, col) : nil
    end

  end
end
