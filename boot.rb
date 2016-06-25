$LOAD_PATH.unshift __dir__
require 'bundler/setup'
ENV['RUBY_ENV'] ||= 'development'

require 'config'
require 'app/logger'

Config.load_and_set_settings Config.setting_files File.join(__dir__, 'config'), ENV['RUBY_ENV']

Logger.init

Logger.get.debug 'App started'
