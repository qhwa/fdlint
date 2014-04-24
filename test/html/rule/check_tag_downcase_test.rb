# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckTagDowncaseTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '标签名必须小写'] do

          should_with_result do
            %Q{<INPUT type="radio" />}
          end

          should_without_result do
            %Q{<input type="radio" />}
          end
        end

        check_rule [:error, '属性名连字符用中横线'] do
          should_with_result do
            [
              %Q{<a data_id="1"/>}
            ]
          end

          should_without_result do
            %Q{<a data-id="1"/>}
          end
        end

        check_rule [:error, '属性名必须小写'] do
          should_with_result do
            [
              %Q{<a dataId="1"/>},
              %Q{<a HREF=""/>},
              %Q{<a Href=""/>}
            ]
          end

          should_without_result do
            %Q{<a href=""/>}
          end
        end

      end
    end
  end
end

