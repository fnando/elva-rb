require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'i18n'
require 'fileutils'

ENV['KARMA_PSTORE_URI'] ||= '/tmp/elva.pstore'
I18n.enforce_available_locales = false
I18n.load_path = Dir[File.expand_path('../../locales/pt-BR.yml', __FILE__)]
I18n.default_locale = 'pt-BR'
