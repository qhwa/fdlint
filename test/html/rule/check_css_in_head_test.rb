# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckCSSInHeadTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:warn, '外链CSS置于head里(例外：应用里的footer样式)'] do

          should_with_result do
            [
              %Q{<link rel="stylesheet" href="test.css"/>},
              %Q{<body><link rel="stylesheet" href="test.css"/></body>}
            ]
          end

          should_without_result do
            %Q{<head><link rel="stylesheet" href="test.css"/></head>}
          end

        end

      end

    end
  end
end
