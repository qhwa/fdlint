require_relative '../helper'
require 'html/parser'
require 'html/query'

module XRayTest
  module HTML

    class QueryTest < Test::Unit::TestCase
      
      include XRay::HTML
      
      def test_query_with_tag_name
        assert Element.new('div') === 'div'
        assert Element.new('a', {:href=>'#'}) === 'a'
      end

      def test_query_with_id
        assert Element.new('div', { :id => 'info' }) === '#info'
        assert Element.new('div', { :id => 'info' }) === 'div#info'
      end

      def test_query_with_class
        assert Element.new('div', { :class => 'info' }) === '.info'
        assert Element.new('div', { :id => 'info-1', :class => 'info' }) === '#info-1.info'
        assert Element.new('div', { :id => 'info-1', :class => 'info' }) === '.info#info-1'
        assert Element.new('div', { :id => 'info-1', :class => 'info' }) === 'div.info#info-1'
      end

      def test_query_with_prop
        assert Element.new('div', { :class => 'info' }) === 'div[class==info]'
      end

      def test_deep_query
        el = ::XRay::HTML::Parser.parse(%Q{<div class="mod">
            <div>
              <ul>
                <li></li>
                <li></li>
              </ul>
            </div>
          </div>})

        assert_equal 2, el.query('li').length
        assert_equal 2, el.query('div').length
        assert_equal 1, el.query('ul').length
        assert_equal 5, el.query('*').length
      end

    end

  end
end
