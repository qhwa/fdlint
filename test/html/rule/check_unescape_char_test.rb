# encoding: utf-8

require_relative '../../helper'

module FdlintTest
  module HTML
    module Rule
      
      class CheckUnescapedCharTest < Test::Unit::TestCase

        include FdlintTest::HTML

        check_rule [:error, '特殊HTML符号(>和<)必须转义'] do

          should_with_result do
            [
              %Q{<test>>>></test>},
              %Q{<a><<<</a>},
              %Q{<a><<<>>></a>}
            ]
          end

          should_without_result do
            [
              %Q{<p/>},
              %Q{<script> 1>5 </script>}
            ]
          end
        end

      end

    end
  end
end
