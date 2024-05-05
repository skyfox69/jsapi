# frozen_string_literal: true

require_relative 'parameter/base'
require_relative 'parameter/reference'

module Jsapi
  module Meta
    module Parameter
      class << self
        # Creates a new parameter or parameter reference.
        def new(name, keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          Base.new(name, keywords)
        end
      end
    end
  end
end
