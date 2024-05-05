# frozen_string_literal: true

require_relative 'callback/base'
require_relative 'callback/reference'

module Jsapi
  module Meta
    module OpenAPI
      module Callback
        class << self
          # Creates a callback or a callback reference.
          def new(keywords = {})
            return Reference.new(keywords) if keywords.key?(:ref)

            Base.new(keywords)
          end
        end
      end
    end
  end
end
