# frozen_string_literal: true

require_relative 'header/model'
require_relative 'header/reference'

module Jsapi
  module Meta
    module Header
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
