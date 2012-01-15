# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckButtonTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal
          src = %q(<button type="button" name="usernmae" />
            <button type="submit" name="male" />
            <button type="reset" name="food" />)
          XRay::HTML::Parser.parse(src).each do |tag|
            assert_equal [], @rule.check_html_tag(tag)
          end
        end

        def test_check_missing_name
          src = %q(<input type="button" value="btn" />
            <input type="submit" name="submit" value="submit"/>
            <input type="reset" />)
          XRay::HTML::Parser.parse(src).each do |tag|
            unless tag.is_a? TextElement
              assert_equal [["所有按钮必须用button（button/submit/reset）", :error]], @rule.check_html_tag(tag)
            end
          end
        end

      end

    end
  end
end



