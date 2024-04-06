# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a license object.
      class License < Object
        attr_accessor :name, :url

        # TODO: validates :name, presence: true

        def to_h
          {
            name: name&.to_s,
            url: url&.to_s
          }.compact
        end
      end
    end
  end
end
