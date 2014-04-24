require 'logger'

module Fdlint; module Helper

  # Public: Module Logger handles the in-application
  #         runtime logging. It helps user inspect
  #         details of application running.
  module Logger

    LEVELS = [:debug, :info, :warn, :error, :fatal]

    # Public: log message with specificated log level
    #
    # msg   - the message text to log
    # level - debug / info / warn / error / fatal
    #
    # Returns nil
    def log( msg, level = :info )
      level = :info unless LEVELS.include?( level )
      send level, msg
    end

    LEVELS.each do |method|
      define_method method do |*args, &block|
        logger.send method, *args, &block
      end
    end

    def logger
      $logger ||= ::Logger.new(STDOUT, ::Logger::WARN)
    end

  end

end; end
