# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class AdditionalProperties < Meta::Base::Model
        delegate_missing_to :schema

        ##
        # :attr: schema
        # The Schema of additional properties.
        attribute :schema, read_only: true

        ##
        # :attr: source
        # The Callable used to read additional properties. By default, additional properties
        # are read by calling the +additional_properties+ method or retrieving the value
        # assigned to the +:additional_properties+ key.
        attribute :source, Callable, default: Callable.from(:additional_properties)

        def initialize(keywords = {})
          keywords = keywords.dup
          super(keywords.extract!(:source))

          @schema = Schema.new(keywords)
        end
      end
    end
  end
end
