# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckFormElementNameTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal
          src = %q(<input type="text" name="usernmae" />
            <input type="radio" name="male" />
            <input type="checkbox" name="food" />
            <textarea name="bio">test</textarea>
            <select name="city"></select>)
          XRay::HTML::Parser.parse(src).each do |tag|
            assert_equal [], @rule.check_tag(tag)
          end
        end

        def test_check_missing_name
          src = %q(<input type="text" />
            <input type="radio" name="" />
            <input type="checkbox" />
            <textarea>test</textarea>
            <select></select>)
          XRay::HTML::Parser.parse(src).each do |tag|
            unless tag.is_a? TextElement
              assert_equal [["text、radio、checkbox、textarea、select必须加name属性", :warn]], @rule.check_tag(tag)
            end
          end
        end

      end

    end
  end
end



