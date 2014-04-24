# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckIDAndClassPropCaseTest < Test::Unit::TestCase

        include FdlintTest::HTML

        should_with_result [:error, "id名称全部小写，单词分隔使用中横线"] do
          %Q{<a id="Nogo" href="#nogo"></a>}
        end

        should_with_result [:error, "class名称全部小写"] do
          %Q{<a class="Nogo" href="#nogo" target="_self"></a>}
        end

        should_with_result [:error, "class名称单词分隔使用中横线"] do
          %Q{<a class="no_go" href="#nogo" target="_self"></a>}
        end

      end

    end
  end
end
