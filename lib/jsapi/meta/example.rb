# frozen_string_literal: true

module Jsapi
  module Meta
    class Example < Base
      ##
      # :attr: description
      # The optional description of the example.
      attribute :description, String

      ##
      # :attr: external
      # If true, +value+ is interpreted as a URI pointing to an external
      # sample value.
      attribute :external, values: [true, false]

      ##
      # :attr: summary
      # The optional summary of the example.
      attribute :summary, String

      ##
      # :attr: value
      # The sample value.
      attribute :value

      # Returns a hash representing the \OpenAPI example object.
      def to_openapi_example
        {}.tap do |hash|
          hash[:summary] = summary if summary.present?
          hash[:description] = description if description.present?

          if external?
            hash[:external_value] = value
          else
            hash[:value] = value
          end
        end
      end
    end
  end
end
