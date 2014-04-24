require_relative '../helper'
require 'fdlint/parser/html/html_parser'
require 'fdlint/parser/html/query'

module FdlintTest
  module HTML

    class QueryTest < Test::Unit::TestCase
      
      include Fdlint::Parser::HTML
      
      def _test_query_with_tag_name
        assert Tag.new('div') === 'div'
        assert Tag.new('a', {:href=>'#'}) === 'a'
      end

      def _test_query_with_id
        assert Tag.new('div', { :id => 'info' }) === '#info'
        assert Tag.new('div', { :id => 'info' }) === 'div#info'
      end

      def test_query_with_class
        assert Tag.new('div', { :class => 'info' }) === '.info'
        #assert Tag.new('div', { :id => 'info-1', :class => 'info' }) === '#info-1.info'
        #assert Tag.new('div', { :id => 'info-1', :class => 'info' }) === '.info#info-1'
        #assert Tag.new('div', { :id => 'info-1', :class => 'info' }) === 'div.info#info-1'
      end

      def _test_query_with_prop
        assert Tag.new('div', { :class => 'info' }) === 'div[class==info]'
      end

      def _test_deep_query
        el = HtmlParser.parse(%Q{<div class="mod">
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
