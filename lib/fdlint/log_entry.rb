# encoding: utf-8
require 'colored'

module Fdlint

  class LogEntry < Struct.new(:message, :level, :row, :column)

    attr_accessor :validation

    def initialize(message, level, row = 0, colmn = 0)
      super
    end

    def to_s
      "[#{level.to_s.upcase}] #{pos} #{message}"
    end

    def pos
      row.nil? ? "" : "[#{row},#{column}]"
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

    def desc
      validation && validation.long_desc
    end


  end

  class InvalidFileEncoding < LogEntry
    def initialize
      super "文件编码错误，无法正常读取", :fatal
    end
  end


end
