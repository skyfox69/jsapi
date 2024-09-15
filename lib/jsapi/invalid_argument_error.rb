# frozen_string_literal: true

module Jsapi
  # Raised when an argument isn't contained in the list of valid values.
  class InvalidArgumentError < ArgumentError
    include InvalidValueHelper

    def initialize(name, value, valid_values: [])
      super(build_message(name, value, valid_values))
    end
  end
end
