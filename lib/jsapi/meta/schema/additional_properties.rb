# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class AdditionalProperties < Meta::Base::Model
        DEFAULT_METHOD_CHAIN = MethodChain.new(:additional_properties) # :nodoc:

        delegate_missing_to :schema

        ##
        # :attr: schema
        # The Schema of additional properties.
        attribute :schema, Schema, writer: false

        ##
        # :attr: source
        # The MethodChain to be called when reading additional properties.
        # The default method is +additional_properties+.
        attribute :source, MethodChain, default: DEFAULT_METHOD_CHAIN

        def initialize(keywords = {})
          keywords = keywords.dup
          super(keywords.extract!(:source))

          @schema = Schema.new(keywords)
        end
      end
    end
  end
end
