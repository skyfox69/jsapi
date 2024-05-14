# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Link
        # Represents a link object.
        class Model < Base
          ##
          # :attr: description
          # The optional description of the link.
          attribute :description, String

          ##
          # :attr: operation_id
          # The operation ID.
          attribute :operation_id, String

          ##
          # :attr: parameters
          # The optional parameters to be passed.
          attribute :parameters, { String => Object }

          ##
          # :attr: request_body
          # The optional request body to be passed.
          attribute :request_body

          ##
          # :attr: server
          # The optional Server object.
          attribute :server, Server

          # Returns a hash representing the link object.
          def to_openapi
            {
              operationId: operation_id,
              parameters: parameters,
              requestBody: request_body,
              description: description,
              server: server&.to_openapi
            }.compact
          end
        end
      end
    end
  end
end
