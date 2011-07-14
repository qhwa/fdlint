require_relative 'helper/color_string'

module XRay

  LogEntry = Struct.new(:message, :level, :row, :column)
  
  class LogEntry

    def initialize(message, level, row = nil, colmn = 0)
      super
    end

    def to_s
      pos = row.nil? ? "" : "[#{row},#{column}]"
      "[#{level.to_s.upcase}] #{pos} #{message}"
    end

    def to_color_s
      t = self.to_s
      if warn?
        t.yellow
      elsif fatal?
        t.white.red_bg
      elsif error?
        t.red.to_s
      else
        t
      end
    end

    def error?
      level == :error
    end

    def warn?
      level == :warn
    end

    def fatal?
      level == :fatal
    end

    def info?
      level == :info
    end

  end

end
