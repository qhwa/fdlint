# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckPropSeperatorTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '属性值必须使用双引号'] do

          should_with_result do
            %Q{<input type='radio' />}
          end

          should_without_result do
            %Q{<input type="radio" />}
          end
        end

      end

    end
  end
end
