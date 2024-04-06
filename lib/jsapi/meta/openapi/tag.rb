# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a tag object.
      class Tag < Object
        attr_accessor :description, :name
        attr_reader :external_docs

        # TODO: validates :name, presence: true

        def external_docs=(keywords)
          @external_docs = ExternalDocumentation.new(**keywords)
        end

        def to_h
          {
            name: name&.to_s,
            description: description&.to_s,
            externalDocs: external_docs&.to_h
          }.compact
        end
      end
    end
  end
end
