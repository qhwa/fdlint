# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckNoCSSImportTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '不通过@import在页面上引入CSS'] do

          should_with_result do
            <<-SRC
              <style>
                @import "style.css"
              </style>
            SRC
          end

          should_without_result do
            <<-SRC
              <style>
                body { background-color: #fff; }
              </style>
            SRC
          end
        end

      end

    end
  end
end
