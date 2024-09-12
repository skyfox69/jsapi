# frozen_string_literal: true

module Jsapi
  module Meta
    # Raised when a value isn't contained in the list of valid values.
    class InvalidValueError < RuntimeError
      include InvalidValueHelper

      def initialize(name, value, valid_values: [])
        super(build_message(name, value, valid_values))
      end
    end
  end
end
