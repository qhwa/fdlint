require_relative '../../helper'

module XRayTest
  module HTML
    module Parser

      class ParseWithSimpleTagTest < Test::Unit::TestCase
        
        include XRay::HTML
        
        def test_data_prop
          parse('<div class="info" data-creater="vim">information</div>') do |element|
            assert_equal Element.new('div', {:class=>'info', :"data-creater" => 'vim' }, [
              TextElement.new('information')
              ]), element
          end
        end

        def parse(src, &block)
          XRay::HTML::Parser.parse(src, &block)
        end
      end

    end
  end
end
