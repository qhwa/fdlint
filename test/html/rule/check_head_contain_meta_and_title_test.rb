# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckHeadTest < Test::Unit::TestCase

        include FdlintTest::HTML

        should_with_result [:error, "head必须包含字符集meta和title"] do
          [
            %Q{<head></head>},

            %Q{<head>
                <title>hello world!</title>
                <meta name="description">
                <meta name="keywords">
              </head>},
              
            %Q{<head>
                <meta charset="utf-8">
                <meta name="description">
                <meta name="keywords">
              </head>}
          ]
        end

        should_without_result [:error, "head必须包含字符集meta和title"] do
          <<-SRC
            <head>
              <meta charset="utf-8">
              <title>hello world!</title>
              <meta name="description">
              <meta name="keywords">
            </head>
          SRC
        end

      end

    end
  end
end
