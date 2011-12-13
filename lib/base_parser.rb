require 'strscan'

require_relative 'node'
require_relative 'parse_error'
require_relative 'position_info'

module XRay
  
  class BaseParser

    attr_reader :log

    def initialize(text, log = nil)
      super()

      @log = log
      text = filter_text(prepare_text(text))
      @pos_info = PositionInfo.new text
      @scanner = StringScanner.new text
    end

    def skip_empty
      pos = scanner_pos
      @scanner.skip /\s*/
      pos
    end
      
    def skip(pattern, not_skip_empty = false)
      not_skip_empty || skip_empty
      pos = scanner_pos
      unless @scanner.skip pattern
        parse_error "skip fail: #{pattern}"
      end
      after_skip(pattern)
      pos
    end

    def check(pattern, not_skip_empty = false)
      last_pos = @scanner.pos
      not_skip_empty || skip_empty
      ret = @scanner.check pattern
      @scanner.pos = last_pos
      ret
    end
      
    def scan(pattern, not_skip_empty = false)
      node = raw_scan pattern, not_skip_empty
      after_scan(pattern)
      node
    end

    def raw_scan(pattern, not_skip_empty = false)
      not_skip_empty || skip_empty
      pos = @pos_info.locate(@scanner.pos)
      text = @scanner.scan pattern
      text ? Node.new(text, pos) : parse_error("scan fail: #{pattern}")
    end
      
    def batch(name, stop = nil, skip_pattern = nil, not_skip_empty = false, &block)
      block = stop ? create_batch_default_block(stop, skip_pattern, not_skip_empty) : block
      result = []
      while !@scanner.eos? && (block ? block.call : true) && item = send(name)
        result << item
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

    protected
    
    def filter_text(text)
      text
    end

    def after_skip(pattern)
    end

    def after_scan(pattern)
    end
    
    def parse_warn(message)
      pos = scanner_pos
      log "#{message}#{pos}", :warn
    end

    def parse_error(message)
      pos = scanner_pos
      log "#{message}#{pos}", :error
      raise ParseError.new(message, pos)
    end
      
    def log(message, level = :info)
      @log && @log.send(level, self.to_s + ': ' + message)
    end

    def scanner_pos
      pos = @scanner.string.size - @scanner.rest.size
      @pos_info.locate(@scanner.eos? ? pos -1 : pos)
    end

    private

    def prepare_text(text)
      text.gsub(/\r\n/, "\n").gsub(/\r/, "\n")
    end

    def create_batch_default_block(stop, skip_pattern, not_skip_empty)
      not_first_time = false
      lambda {
        if check(stop, not_skip_empty)
          false
        else
          not_first_time  && skip_pattern && skip(skip_pattern)
          not_first_time = true
          true
        end
      }
    end

  end

end
