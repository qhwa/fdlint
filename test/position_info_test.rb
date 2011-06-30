# encoding: utf-8
require_relative 'helper'

require 'position_info'

module XRayTest
  
  class PositionInfoTest < Test::Unit::TestCase

    PositionInfo = XRay::PositionInfo
    Position = XRay::Position

    @@test_paragraph = %(this is line one
   this is line two this is line two  
 this is line three  
       this is ine 4   )

    def test_position_of_first_line
        text, info, lines = prepair @@test_paragraph
        len = lines[0].length
        assert_equal Position.new(0,0,0), info.locate(0), "第一行第一个字符"
        assert_equal Position.new(6,0,6), info.locate(6), "第一行第7个字符"
        assert_equal Position.new(len-1, 0, len-1), info.locate(len-1), "第一行最后一个字符"
    end

    def test_position_of_middle_line
        text, info, lines = prepair @@test_paragraph
        len = lines[0].length
        assert_equal Position.new(len, 1, 0), info.locate(len), "第2行的第一个字符"
        assert_equal Position.new(len+1, 1, 1), info.locate(len+1), "第2行的第2个字符"
        assert_equal Position.new(len+5, 1, 5), info.locate(len+5), "第2行的第6个字符"
    end
    
    def test_position_of_last_line
        text, info, lines = prepair @@test_paragraph
        len = 0
        (0..2).each {|n| len += lines[n].length }
        assert_equal Position.new(len, 3, 0), info.locate(len), "第4行的第一个字符"
        assert_equal Position.new(len+1, 3, 1), info.locate(len+1), "第4行的第2个字符"
        assert_equal Position.new(len+5, 3, 5), info.locate(len+5), "第4行的第6个字符"
    end

    def prepair( text )
        info = PositionInfo.new text
        lines = text.split("\n").map { |l| "#{l}\n" }
        [text, info, lines]
    end
  end
end
