require_relative '../base_parser'
require_relative 'struct'

require_relative 'expr/simple'
require_relative 'expr/primary'

require_relative 'stat/simple'
require_relative 'stat/var'


module XRay
  module JS
    
    class Parser < XRay::BaseParser

      include Expr::Simple
      include Expr::Primary

      include Stat::Simple
      include Stat::Var


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

      def parse_function_declaration
        log 'parse function declaration'

        pos = skip /function/

        name = check(/\(/) ? nil : parse_expr_identifier

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
