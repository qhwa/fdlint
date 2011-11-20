require_relative '../base_parser'
require_relative 'struct'

require_relative 'expr/expr'
require_relative 'expr/primary'
require_relative 'expr/left_hand'
require_relative 'expr/postfix'

require_relative 'stat/stat'
require_relative 'stat/var'

module XRay
  module JS
    
    class Parser < XRay::BaseParser

      include Expr::Expr
      include Expr::Primary
      include Expr::LeftHand
      include Expr::Postfix

      include Stat::Stat
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
        
        FunctionDeclaraion.new name, args, body, pos
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
