# frozen_string_literal: true

# SimpleCov
require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  enable_coverage :branch
end

# Copied form SimpleCov's Minitest plug-in:
SimpleCov.external_at_exit = true
Minitest.after_run do
  SimpleCov.at_exit_behavior
end

# Pry
require 'pry'

# Active Support
require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/array'
require 'active_support/core_ext/string'

# Load locale to test error messages
ActiveSupport.on_load(:i18n) do
  I18n.load_path << File.expand_path('config/locale/en.yml', __dir__)
end

# Define dummy API controller
module ActionController
  class API; end
end

# This gem
require 'jsapi'

# Start Minitest
require 'minitest/autorun'
