# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckButtonTest < Test::Unit::TestCase

        include FdlintTest::HTML

        def setup
          @button_err = [:error, "所有按钮必须用button（button/submit/reset）"]
        end

        def test_check_normal
          src = %q(<button type="button" name="usernmae" />
            <button type="submit" name="male" />
            <button type="reset" name="food" />)
          parse src do |results|
            assert_not_has_result results, @button_err
          end
        end

        def test_check_missing_name
          src = %q(<input type="button" value="btn" />
            <input type="submit" name="submit" value="submit"/>
            <input type="reset" />)

          src.each_line do |src|
            parse src do |results|
              assert_has_result results, @button_err
            end
          end
        end

      end

    end
  end
end



