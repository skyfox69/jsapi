# frozen_string_literal: true

require_relative 'request_body/base'
require_relative 'request_body/reference'

module Jsapi
  module Meta
    module RequestBody
      class << self
        # Creates a Base or Reference.
        def new(keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          Base.new(keywords)
        end
      end
    end
  end
end
