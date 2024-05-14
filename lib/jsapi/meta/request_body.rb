# frozen_string_literal: true

require_relative 'request_body/model'
require_relative 'request_body/reference'

module Jsapi
  module Meta
    module RequestBody
      class << self
        # Creates a new request body model or reference.
        def new(keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          Model.new(keywords)
        end
      end
    end
  end
end
