require 'logging'

class Logger
  class << self
    def get(target = nil)
      return Logging.logger[target] if target
      Logging.logger.root
    end

    def init
      settings = Settings.log
      appenders = []
      if settings.stdout.enabled
        stdout = Logging.appenders.stdout(
          layout: Logging::Layouts::Pattern.new,
          level: settings.stdout.level
        )
        appenders << stdout
      end
      Logging.logger.root.appenders = appenders
      Logging.logger.root.level = :debug
    end
  end
end
