# frozen_string_literal: true

require_relative 'parameter/model'
require_relative 'parameter/reference'

module Jsapi
  module Meta
    module Parameter
      class << self
        # Creates a new parameter model or reference.
        def new(name, keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          Model.new(name, keywords)
        end
      end
    end
  end
end
