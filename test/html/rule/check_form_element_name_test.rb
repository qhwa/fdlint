# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckFormElementNameTest < Test::Unit::TestCase

        include FdlintTest::HTML

        def setup
          @err = [:error, 'text、radio、checkbox、textarea、select必须加name属性']
        end

        def test_check_normal
          src = %q(<input type="text" name="usernmae" />
            <input type="radio" name="male" />
            <input type="checkbox" name="food" />
            <textarea name="bio">test</textarea>
            <select name="city"></select>)
          src.each_line do |src|
            parse src do |results|
              assert_not_has_result results, @err
            end
          end
        end

        def test_check_missing_name
          src = %q(<input type="text" />
            <input type="radio" name="" />
            <input type="checkbox" />
            <textarea>test</textarea>
            <select></select>)
          src.each_line do |src|
            parse src do |results|
              assert_has_result results, @err
            end
          end
        end

      end

    end
  end
end



