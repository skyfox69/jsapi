# frozen_string_literal: true

module Jsapi
  # Holds the Jsapi configuration.
  class Configuration
    ##
    # :attr: path
    # The path of the API definitions relative to the Rails root. The default path is
    # <code>"app/api_definitions"</code>.
    attr_accessor :path

    def initialize
      @path = 'app/api_definitions'
    end

    # Returns the absolute +Pathname+ for +args+ within the API definitions path.
    def pathname(*args)
      return unless (root = Rails.root)

      root.join(*[path, args].flatten)
    end
  end

  class << self
    # The singleton Jsapi configuration.
    def configuration
      @configuration ||= Configuration.new
    end
  end
end
