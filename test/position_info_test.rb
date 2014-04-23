# encoding: utf-8

require_relative 'helper'

require 'fdlint/parser/position_info'

module FdlintTest
  
  class PositionInfoTest < Test::Unit::TestCase

    PositionInfo = Fdlint::Parser::PositionInfo
    Position     = Fdlint::Parser::Position

    @@test_paragraph = %(this is line one
   this is line two this is line two    
 this is line three  
       this is ine 4 
        中文字行数
  打算怎么办
         )

    def test_position_of_first_line
        text, info, lines = prepair @@test_paragraph
        len = lines[0].length
        assert_equal Position.new(0, 1, 1), info.locate(0), '第一行第一个字符'
        assert_equal Position.new(6, 1, 7), info.locate(6), '第一行第7个字符'
        assert_equal Position.new(len - 1, 1, len), info.locate(len - 1), '第一行最后一个字符'
    end

    def test_position_of_middle_line
        text, info, lines = prepair @@test_paragraph
        len = lines[0].length
        assert_equal Position.new(len, 2, 1), info.locate(len), '第2行的第一个字符'
        assert_equal Position.new(len + 1, 2, 2), info.locate(len + 1), '第2行的第2个字符'
        assert_equal Position.new(len + 5, 2, 6), info.locate(len + 5), '第2行的第6个字符'
    end
    
    def test_position_of_4th_line
        text, info, lines = prepair @@test_paragraph
        len = 0
        (0..2).each {|n| len += lines[n].length }
        assert_equal Position.new(len, 4, 1), info.locate(len), '第4行的第一个字符'
        assert_equal Position.new(len + 1, 4, 2), info.locate(len + 1), '第4行的第2个字符'
        assert_equal Position.new(len + 5, 4, 6), info.locate(len + 5), '第4行的第6个字符'
    end

    def test_position_all_line
        text, info, lines = prepair @@test_paragraph
        pos = 0
        lines.each_with_index do |line, row|
          0.upto(line.length - 1) do |col|
            assert_equal Position.new(pos, row + 1, col + 1), info.locate(pos)
            pos += 1
          end
        end
    end

    def prepair(text)
        info = PositionInfo.new text
        lines = text.split("\n").map { |l| "#{l}\n" }
        [text, info, lines]
    end

  end
end
