# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckHyperlinkWithTargetTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:warn, '功能a必须加target="_self"，除非preventDefault过'] do

          should_with_result do
            [
              %Q{<a href="#nogo"></a>},

              %Q{
                <base target="_blank">
                <a href="#nogo"></a>
              }
            ]
          end

          should_without_result do
            [
              %Q{<a href="#nogo" target="_self"></a>},

              %Q{
                <base target="_self">
                <a href="#nogo"></a>
              }
            ]
          end

        end

      end

    end
  end
end



