module XRay
  module JS
    module Stat 
      
      module Statement 
        def parse_statement
          log 'parse statement'

          stat = scan /[^;]*;/
          log stat.text
          stat
        end
      end
       
    end
  end
end
