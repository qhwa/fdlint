require_relative '../base_parser'
require_relative 'struct'

require_relative 'expr/expr'
require_relative 'stat/stat'


module XRay
  module JS
    
    class Parser < XRay::BaseParser

      include Expr::Expr
      include Stat::Stat


      def parse_program(inner = false)
        log 'parse program'
        elms = batch(:parse_source_element) do
          skip_empty
          inner ? !check(/}/) : !eos? 
        end
        Program.new elms
      end

      def parse_source_element
        log 'parse source_element'

        check(/function\b/) ? parse_function_declaration : parse_statement
      end

      def parse_function_declaration(force_name = true)
        log 'parse function declaration'

        pos = skip /function/

        name = (force_name || !check(/\(/)) ? parse_expr_identifier : nil
        skip /\(/
        params = batch(:parse_expr_identifier, /\)/, /,/)
        skip /\)\s*\{/
        body = parse_program(true)
        skip /}/
        
        FunctionDeclaraion.new name, params, body, pos
      end

      protected

      def filter_text(js)
        filter_comment js
      end

      private
      
      def filter_comment(js)
        res = [/\/\*[^*]*\*+([^\/*][^*]*\*+)*\//, /\/\/.*$/]
        res.each do |re|
          js = js.gsub(re) do |m|
            log "ignore comments: \n#{m}"
            m.gsub /\S/, ' '
          end
        end 
        js 
      end
    end

  end
end
