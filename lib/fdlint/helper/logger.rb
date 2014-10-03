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
    def log( msg, level = :info, &block )
      level = :info unless LEVELS.include?( level )
      logger.send level, msg, &block
    end

    LEVELS.each do |method|
      define_method method do |*args, &block|
        logger.send method, *args, &block
      end
    end

    def logger
      $logger ||= ::Logger.new(STDOUT).tap { |logger| logger.level = ::Logger::WARN }
    end

  end

end; end
