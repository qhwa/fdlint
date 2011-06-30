module XRay

  Position = Struct.new(:pos, :line, :column)
  class Position
    def to_s
        "[#{line + 1},#{column + 1}]"
    end
  end

  class PositionInfo
  
    def initialize(text)
      lines = (text || '').split(/\r?\n/)
      @lines_info = lines.map(&:length)
    end

    def locate(pos)
      line = 0
      col = pos
      now = @lines_info[line]
      while now && col > now
        col -= (now + 1)
        line += 1
        now = @lines_info[line]
      end
      now ? Position.new(pos, line, col) : nil
    end

    alias_method :position, :locate

  end

end
