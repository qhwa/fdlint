# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckImgWithAltPropTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, 'img标签必须加上alt属性'] do

          should_with_result do
            %Q{<img src="http://pnq.cc/icon.png" />}
          end

          should_without_result do
            %Q{<img src="http://pnq.cc/icon.png" alt="test" />}
          end

        end

      end

    end
  end
end



