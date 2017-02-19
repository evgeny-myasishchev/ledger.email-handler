require 'logging'

class Logger
  class << self
    def get(target = nil)
      return Logging.logger[target] if target
      Logging.logger.root
    end

    def init
      appenders = []
      append_stdout_appender appenders
      append_file_appender appenders
      append_syslog_appender appenders
      Logging.logger.root.appenders = appenders
      Logging.logger.root.level = :debug
    end

    private def append_stdout_appender(appenders)
      settings = Settings.log
      if settings.stdout.enabled
        stdout = Logging.appenders.stdout(
          layout: Logging::Layouts::Pattern.new,
          level: settings.stdout.level
        )
        appenders << stdout
      end
    end

    private def append_file_appender(appenders)
      settings = Settings.log
      if settings.file.enabled
        stdout = Logging.appenders.file(settings.file.path,
                                        layout: Logging::Layouts::Pattern.new,
                                        level: settings.file.level)
        appenders << stdout
      end
    end

    private def append_syslog_appender(appenders)
      settings = Settings.log
      if settings.syslog.enabled
        syslog = Logging.appenders.syslog(settings.syslog.name,
                                          ident: settings.syslog.ident)
        appenders << syslog
      end
    end
  end
end
