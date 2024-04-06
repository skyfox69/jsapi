# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a server object.
      class Server < Object
        attr_accessor :description, :url, :variables

        # TODO: validates :url, presence: true

        def add_variable(name, keywords)
          (@variables ||= {})[name.to_s] = ServerVariable.new(**keywords)
        end

        def to_h
          {
            description: description&.to_s,
            url: url&.to_s,
            variables: variables&.transform_values(&:to_h)
          }.compact
        end
      end
    end
  end
end
