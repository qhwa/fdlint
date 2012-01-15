# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckClassCountTest < Test::Unit::TestCase

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
        end

        def test_check_normal
          prop = XRay::HTML::Property.new('class', 'info')
          assert_equal [], @rule.check_html_property(prop)
        end

        def test_check_too_many_classes
          prop = XRay::HTML::Property.new('class', 'info new red bigger')
          expected = ["一个节点上定义的class个数最多不超过3个(不含lib中的class)", :error]
          assert_equal [expected], @rule.check_html_property(prop)
        end

        def test_check_filter_fdev_classes
          prop = XRay::HTML::Property.new('class', 'info new red fd-main w952 layout grid layout- grid-')
          assert_equal [], @rule.check_html_property(prop)
        end

      end

    end
  end
end
