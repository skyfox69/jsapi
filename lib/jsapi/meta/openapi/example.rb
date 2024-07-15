# frozen_string_literal: true

require_relative 'example/model'
require_relative 'example/reference'

module Jsapi
  module Meta
    module OpenAPI
      module Example
        class << self
          # Creates a new example model or reference.
          def new(keywords = {})
            return Reference.new(keywords) if keywords.key?(:ref)

            Model.new(keywords)
          end
        end
      end
    end
  end
end
