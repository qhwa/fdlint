# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckBlockLevelElementTest < Test::Unit::TestCase

        include FdlintTest::HTML

        def setup
          @block_level_err = [:error, "行内标签不得包含块级标签，a标签例外"]
        end

        def test_check_normal
          src = %Q{<div><span>good day, commander!</span></div>}
          parse src do |results|
            assert_not_has_result results, @block_level_err
          end
        end

        def test_check_block_in_inline
          src = %Q{<span><div>good day, commander!</div></span>}
          parse src do |results|
            assert_has_result results, @block_level_err
          end
        end

        def test_check_inline_inline_block
          src = %Q{<span><span>good day, commander!</span></span>}
          parse src do |results|
            assert_not_has_result results, @block_level_err
          end
        end

        def test_check_block_in_a
          src = %Q{<a><div>good day, commander!</div></a>}
          parse src do |results|
            assert_not_has_result results, @block_level_err
          end
        end

      end

    end
  end
end

