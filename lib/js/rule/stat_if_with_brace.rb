# encoding: utf-8

module XRay
  module JS
    module Rule
     
      class StatIfWithBrace
        
        def visit_stat_if(stat)
          if stat.true_part.type != 'block' ||
              stat.false_part && stat.false_part.type != 'if' && stat.false_part.type != 'block'
            
            ['所有条件区域必须用花括号括起来', :error]
          end
        end
         
      end
    
    end
  end
end
