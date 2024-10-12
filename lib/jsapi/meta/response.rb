# frozen_string_literal: true

require_relative 'response/model'
require_relative 'response/reference'

module Jsapi
  module Meta
    module Response
      class << self
        # Creates a Model or Reference.
        def new(keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          Model.new(keywords)
        end
      end
    end
  end
end
