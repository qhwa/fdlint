# encoding: utf-8

require_relative '../helper'

module XRayTest

  module Rule
  
    class ImportingTest < Test::Unit::TestCase

      include ::XRay::Rule

      def setup
        clear_all_rules
      end
      
      def test_import_with_symbol
        import :css
        assert css_rules.size > 0
      end

      def test_import_with_symbol_twice
        assert_equal 0, css_rules.size

        import :css
        size = css_rules.size
        assert size > 0

        import :css
        assert_equal size, css_rules.size
      end

      def test_import_all_twice
        assert_equal 0, css_rules.size

        import_all
        size = css_rules.size
        assert size > 0

        import_all
        assert_equal size, css_rules.size
        
      end

    end

  end
end
