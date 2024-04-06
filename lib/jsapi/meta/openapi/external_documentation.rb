# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents an external documentation object.
      class ExternalDocumentation < Object
        attr_accessor :description, :url

        # TODO: validates :url, presence: true

        def to_h
          {
            description: description&.to_s,
            url: url&.to_s
          }.compact
        end
      end
    end
  end
end
