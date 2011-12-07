# encoding: utf-8

module XRay
  module JS
    module Rule
     
      class Semicolon
        
        def visit_statement(stat)
          ary = %w(empty var continue break return throw expression)
          if ary.include?(stat.type) && !stat.end_with_semicolon?
            ['所有语句结束带上分号', :error] 
          end
        end
         
      end
    
    end
  end
end
