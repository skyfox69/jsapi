# frozen_string_literal: true

require_relative 'callback/model'
require_relative 'callback/reference'

module Jsapi
  module Meta
    module Callback
      class << self
        # Creates a callback model or reference.
        def new(keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          Model.new(keywords)
        end
      end
    end
  end
end
