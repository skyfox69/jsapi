# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Array < Base
        ##
        # :attr: items
        # The Schema defining the kind of items.
        attribute :items, Schema

        ##
        # :attr: max_items
        # The maximum length of an array.
        attribute :max_items, writer: false

        ##
        # :attr: min_items
        # The minimum length of an array.
        attribute :min_items, writer: false

        def max_items=(value) # :nodoc:
          add_validation('max_items', Validation::MaxItems.new(value))
          @max_items = value
        end

        def min_items=(value) # :nodoc:
          add_validation('min_items', Validation::MinItems.new(value))
          @min_items = value
        end

        def to_json_schema # :nodoc:
          super.merge(items: items&.to_json_schema || {})
        end

        def to_openapi_schema(version) # :nodoc:
          super.merge(items: items&.to_openapi_schema(version) || {})
        end
      end
    end
  end
end
