# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckUniqueImportTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '避免重复引用同一文件'] do

          should_with_result do
            [
              %Q{<script src="fdev-min.js"></script>} * 2,
              %Q{<script src="fdev-min.js"></script>} * 5,
              %Q{<link rel="stylesheet" href="test.css"/>} * 2,
              %Q{<link rel="stylesheet" href="test.css"/>} * 5
            ]
          end

          should_without_result do
            [
              %Q{<script src="fdev-min.js"></script>},
              %Q{<link rel="stylesheet" href="test.css"/>}
            ]
          end
        end

      end

    end
  end
end


