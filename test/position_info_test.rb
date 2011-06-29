require_relative 'helper'

require 'position_info'

module XRayTest
  
  class PositionInfoTest < Test::Unit::TestCase

    PositionInfo = XRay::PositionInfo
    
    def test_position
      lines = [
        "this is line one\n",
        "   this is line two this is line two  \n",
        " this is line three  \n",
        "       this is ine 4   "
      ]
      text = lines.join('')

      info = PositionInfo.new(text)
      assert_pos_equal(info, 0, [0, 0, 0])
      assert_pos_equal(info, 6, [6, 0, 6])

      n1 = lines[0].length
      assert_pos_equal(info, n1 - 1, [n1 - 1, 0, n1 - 1])
      assert_pos_equal(info, n1, [n1, 1, 0])
      assert_pos_equal(info, n1 + 2, [n1 + 2, 1, 2])

      assert_pos_equal(info, n1 + 5, [n1 + 5, 1, 5])
      assert_pos_equal(info, n1 + 10, [n1 + 10, 1, 10])

      n2 = lines[1].length
      assert_pos_equal(info, n1 + n2 - 2, [n1 + n2 - 2, 1, n2 - 2])
      assert_pos_equal(info, n1 + n2 - 1, [n1 + n2 - 1, 1, n2 - 1])
      assert_pos_equal(info, n1 + n2, [n1 + n2, 2, 0])
      assert_pos_equal(info, n1 + n2 + 1, [n1 + n2 + 1, 2, 1])
      assert_pos_equal(info, n1 + n2 + 3, [n1 + n2 + 3, 2, 3])
    end

    def assert_pos_equal(info, pos, expect)
      pos = info.position(pos)
      assert_equal expect[0], pos.pos
      assert_equal expect[1], pos.line
      assert_equal expect[2], pos.column
    end
  
  end
end
