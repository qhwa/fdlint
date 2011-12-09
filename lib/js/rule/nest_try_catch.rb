# encoding: utf-8

module XRay
  module JS
    module Rule
     
      class NestTryCatch 

        def visit_stat_try(stat)
          if contain_try?(stat.try_part) ||
              stat.catch_part && contain_try?(stat.catch_part) ||
              stat.finally_part && contain_try?(stat.finally_part)
            ['try catch一般不允许嵌套，若嵌套，需要充分的理由', :warn]
          end
        end

        private

        def contain_try?(stat)
          case stat.type
          when 'block'
            stat.elements.any? { |elm| contain_try? elm } 
          when 'if'
            contain_try?(stat.true_part) ||
                stat.false_part && contain_try?(stat.false_part)
          when 'switch'
            contain_try? stat.case_block
          when 'dowhile', 'while', 'for'
            contain_try? stat.body
          when 'try'
            true
          end
        end
         
      end
    
    end
  end
end
