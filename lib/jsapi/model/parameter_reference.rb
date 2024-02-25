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

      # Returns the OpenAPI reference object as an +Array+ containing a single +Hash+.
      def to_openapi_parameters(version, _definitions = nil)
        path = version == '2.0' ? 'parameters' : 'components/parameters'

        [{ '$ref': "#/#{path}/#{reference}" }]
      end
    end
  end
end
