# encoding: utf-8

module XRay
  module JS
    module Rule
     
      class StatIfWithMutiElse
        
        def visit_stat_if(stat)
          count = 0;
          while stat.false_part && stat.false_part.type == 'if'
            count += 1
            stat = stat.false_part
          end
          count += 1 if stat.false_part
          
          ['3个条件及以上的条件语句用switch代替if else', :warn] if count >= 3
        end
         
      end
    
    end
  end
end
