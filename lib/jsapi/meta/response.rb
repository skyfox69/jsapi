# frozen_string_literal: true

require_relative 'response/base'
require_relative 'response/reference'

module Jsapi
  module Meta
    module Response
      class << self
        # Creates a new response or response reference.
        def new(keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          Base.new(keywords)
        end
      end
    end
  end
end
