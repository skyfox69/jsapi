# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Array < Base
        ##
        # :attr: items
        # The Schema defining the kind of items.
        attribute :items, Schema, accessors: %i[reader]

        ##
        # :attr: max_items
        # The maximum length of an array.
        attribute :max_items, accessors: %i[reader]

        ##
        # :attr: min_items
        # The minimum length of an array.
        attribute :min_items, accessors: %i[reader]

        def items=(keywords = {}) # :nodoc:
          if keywords.key?(:schema)
            keywords = keywords.dup
            keywords[:ref] = keywords.delete(:schema)
          end
          @items = Schema.new(keywords)
        end

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

        def to_openapi(version, *) # :nodoc:
          super.merge(items: items&.to_openapi(version) || {})
        end
      end
    end
  end
end
