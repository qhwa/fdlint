# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckTagClosedTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '标签必须正确闭合'] do

          should_without_result do
            [
              %Q{<br>},
              %Q{<br/>},
              %Q{<p></p>},
              %Q{<p/>},
              %Q{<img src="" alt="" >},
              %Q{<img src="" alt="" />},
              %Q{text},
              %Q{<!--comment-->}
            ]
          end
        end

      end

    end
  end
end

