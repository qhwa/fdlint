require 'fdlint/parser/node'
require 'fdlint/parser/parse_error'
require 'fdlint/parser/position_info'
require 'strscan'

module Fdlint

  module Parser
    
    class BaseParser

      include ::Fdlint::Helper::Logger

      attr_reader :source

      def initialize(text)
        @source    = prepare_text(text).freeze
        @pos_info  = PositionInfo.new @source
        @scanner   = StringScanner.new @source
        @text_size = text.size
      end

      EMPTY_STRING_OR_NONE = /\s*/.freeze
      def skip_empty
        @scanner.skip(EMPTY_STRING_OR_NONE)
      end
        
      def skip(pattern, not_skip_empty = false)
        not_skip_empty || skip_empty
        pos = scanner_pos
        unless @scanner.skip pattern
          parse_error pattern
        end
        after_skip pattern
        pos
      end

      def scanner_pos
        @pos_info.locate_with_bytepos @scanner.pos
      end

      EMPTY_STRINGS = /\s+/
      NON_EMPTY_STRING = /(?=\S)/.freeze
      def check(pattern, not_skip_empty = false)
        unless not_skip_empty
          last_pos = @scanner.pos
          @scanner.skip_until NON_EMPTY_STRING
        end
        ret = @scanner.check( pattern )
        @scanner.pos = last_pos if last_pos
        ret
      end
        
      def scan(pattern, not_skip_empty = false)
        node = raw_scan pattern, not_skip_empty
        after_scan pattern
        node
      end

      def raw_scan(pattern, not_skip_empty = false)
        not_skip_empty || skip_empty
        pos = scanner_pos
        text = @scanner.scan pattern
        text ? Node.new(text, pos) : parse_error(pattern)
      end
        
      def batch(name, stop = nil, skip_pattern = nil, not_skip_empty = false, &block)
        first = true
        result = []
        while !@scanner.eos? && 
            (stop ? batch_check(stop, skip_pattern, not_skip_empty, first) : 
                block ? block.call : true) && 
            item = send(name)
          result << item
          first = false
        end
        result
      end
      
      def to_s
        self.class.to_s
      end
      
      def reset
        @scanner.reset
      end

      def eos?
        @scanner.eos?
      end

      def scanned_source
        pos = @text_size - @scanner.rest.size
        source[0..(pos-1)]
      end

      def rest_source
        @scanner.rest
      end

      protected
      
      def after_skip(pattern)
      end

      def after_scan(pattern)
      end
      
      def parse_warn(message)
        pos = scanner_pos
        log "#{message}#{pos}", :warn
      end

      def parse_error(pattern)
        if pattern.respond_to?(:source)
          message = "should be #{pattern.source} here"
        else
          message = pattern.to_s
        end
        pos = scanner_pos
        log "#{message} #{pos}", :error
        raise ParseError.new(message, pos)
      end
        
      private

      def prepare_text(text)
        if text.respond_to? :encode!
          text.encode 'utf-8', :invalid => :replace, :universal_newline => true
        else
          text.gsub(/\r\n/, "\n").gsub(/\r/, "\n")
        end
      end
      
      def batch_check(stop, skip_pattern, not_skip_empty, first)
        if check stop, not_skip_empty
          false
        else
          !first && skip_pattern && skip(skip_pattern) 
          true
        end
      end

    end

  end
end
