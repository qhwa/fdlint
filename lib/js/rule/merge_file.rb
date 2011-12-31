# encoding: utf-8

module XRay
  module JS
    module Rule
      
      class MergeFile

        def initialize(options = {})
          @options = options
          @path = options[:path]
        end
        
        def visit_expr_member(expr)
          return unless merge_file? && 
              expr.type == '(' &&
              expr.left.text = '(.,ImportJavscript,url)'
        
          
        end
        
        def merge_file?
          @path && @path =~ /\w-merge\d*\.js$/
        end
         
      end

    end
  end
end
