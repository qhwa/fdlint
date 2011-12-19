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

      @lines = []
      num = 0
      lines.each do |line|
        num += line.length + 1
        @lines << num
      end

      @len = lines.length
    end

    def locate(pos)
      if @row && pos >= @lines[@row -1] && pos < @lines[@row]
        row = @row
      else
        row = @row = find(0, @len - 1, pos)
      end
      col = row > 0 ? pos - @lines[row - 1] : pos
      Position.new(pos, row + 1, col + 1)
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
