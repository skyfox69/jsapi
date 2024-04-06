# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a server variable object.
      class ServerVariable < Object
        attr_accessor :default, :description, :enum

        # TODO: validates :default, presence: true

        def to_h
          {
            enum: Array(enum).presence,
            default: default&.to_s,
            description: description&.to_s
          }.compact
        end
      end
    end
  end
end
