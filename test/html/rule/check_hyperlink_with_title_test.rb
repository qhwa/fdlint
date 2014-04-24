# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckHyperlinkWithTitleTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '非功能能点的a标签必须加上title属性'] do

          should_with_result do
            %Q{<a href="new-page.html"></a>}
          end

          should_without_result do
            [
              %Q{<a href="new-page.html" title="new page"></a>},

              %Q{<a href="#nogo"></a>}
            ]
          end

        end

      end

    end
  end
end



