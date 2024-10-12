# frozen_string_literal: true

require_relative 'link/model'
require_relative 'link/reference'

module Jsapi
  module Meta
    module Link
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
