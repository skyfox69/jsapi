# frozen_string_literal: true

module Jsapi
  module Meta
    # Holds the default values for a particular Schema type.
    class Defaults < Base::Model
      ##
      # :attr: within_requests
      # The default value of parameters and properties when reading requests.
      attribute :within_requests

      ##
      # :attr: within_responses
      # The default value of properties when writing responses.
      attribute :within_responses

      # Returns the default value within +context+.
      def value(context:)
        case context
        when :request
          within_requests
        when :response
          within_responses
        end
      end
    end
  end
end
