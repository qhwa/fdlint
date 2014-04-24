# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckPropHaveValueTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '不能仅有属性名'] do

          should_with_result do
            %Q{<input type="radio" checked />}
          end

          should_without_result do
            %Q{<input type="radio" checked="true" />}
          end
        end

      end

    end
  end
end
