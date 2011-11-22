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
        Program.new parse_source_elements
      end

      def parse_source_element
        log 'parse source_element'

        check(/function\b/) ? parse_function_declaration : parse_statement
      end

      def parse_function_declaration(skip_name = false)
        log 'parse function declaration'

        pos = skip /function/

        name = (skip_name && check(/\(/)) ? nil : parse_expr_identifier
        skip /\(/
        params = batch(:parse_expr_identifier, /\)/, /,/)
        skip /\)\s*\{/
        body = parse_source_elements true
        skip /}/
         
        FunctionDeclaraion.new name, Elements.new(params), body, pos
      end

      protected

      def filter_text(js)
        filter_comment js
      end

      def create_element(klass, *args)
        elm = klass.new *args
        log "  #{elm}"
        elm
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
      
      def parse_source_elements(inner = false)
        elms = batch(:parse_source_element) do
          skip_empty
          inner ? !check(/}/) : !eos? 
        end
        Elements.new elms
      end

    end

  end
end
