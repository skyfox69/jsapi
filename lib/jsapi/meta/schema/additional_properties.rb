# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class AdditionalProperties < Meta::Base
        #
        # :attr: schema
        # The Schema of additional properties.
        attribute :schema, Schema, writer: false

        ##
        # :attr: source
        # The method to read additional properties when serializing an object.
        # The default method is +additional_properties+.
        attribute :source, Symbol, default: :additional_properties

        delegate_missing_to :schema

        def initialize(keywords = {})
          keywords = keywords.dup
          super(keywords.extract!(:source))

          @schema = Schema.new(keywords)
        end
      end
    end
  end
end
