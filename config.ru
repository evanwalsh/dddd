require 'rubygems'
require 'bundler'

Bundler.require

require 'raven'
Raven.configure do |config|
  config.dsn = ENV['SENTRY_URL']
end

Raven.capture do
  require './app'
  run App
end