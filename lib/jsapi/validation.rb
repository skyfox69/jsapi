# frozen_string_literal: true

require_relative 'validation/error'
require_relative 'validation/errors'
require_relative 'validation/attribute_error'

module Jsapi
  # ActiveRecord-like validation
  module Validation
    # Invoked by +errors+ to validate the object
    def _validate; end

    def errors
      unless instance_variable_defined?(:@errors)
        @errors = Errors.new
        _validate
      end
      @errors
    end

    def valid?
      errors.none?
    end

    def invalid?
      errors.any?
    end
  end
end
