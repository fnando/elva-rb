ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup'
require 'socket'
require 'logger'
require 'ostruct'
require 'i18n'
require 'aitch'

require_relative 'elva/client'
require_relative 'elva/handlers/base'

require_relative 'elva/handlers/gem'
require_relative 'elva/handlers/gist'
require_relative 'elva/handlers/github'
require_relative 'elva/handlers/google'
require_relative 'elva/handlers/help'
require_relative 'elva/handlers/karma'
require_relative 'elva/handlers/npm'
require_relative 'elva/handlers/ping'
require_relative 'elva/handlers/tell'
require_relative 'elva/handlers/tweet'

I18n.enforce_available_locales = false
I18n.default_locale = ENV.fetch('LOCALE', :en)
I18n.load_path += Dir[File.expand_path('../../locales/**/*.yml', __FILE__)]
