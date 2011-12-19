module XRay

  Position = Struct.new(:pos, :row, :column)
  class Position
    def to_s
        "[#{row},#{column}]"
    end
  end

  class PositionInfo
  
    def initialize(text)
      lines = text.split(/\n/)
      @lines_info = lines.map &:length
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

      Position.new(pos, row + 1, col + 1)
    end

  end
end
