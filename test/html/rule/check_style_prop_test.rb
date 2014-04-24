# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckStylePropTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '不能定义内嵌样式style'] do

          should_with_result do
            %Q{<div style='background:transparent;' />}
          end

        end

      end

    end
  end
end
