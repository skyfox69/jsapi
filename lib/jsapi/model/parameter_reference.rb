# frozen_string_literal: true

module Jsapi
  module Model
    class ParameterReference
      attr_reader :reference

      def initialize(reference)
        @reference = reference
      end

      # Resolves the reference by looking up the reusable parameter in +definitions+.
      # Raises a +ReferenceError+ if the reference could not be resolved.
      def resolve(definitions)
        parameter = definitions.parameter(reference)
        raise ReferenceError, reference if parameter.nil?

        parameter
      end

      # Returns the OpenAPI reference object as an array containing a single hash.
      def to_openapi_parameters
        [{ '$ref': "#/components/parameters/#{reference}" }]
      end
    end
  end
end
