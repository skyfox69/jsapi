# frozen_string_literal: true

module Jsapi
  module DSL
    class Schema < Node
      COMMON_METHODS = %i[
        default
        enum
        exclusive_maximum
        exclusive_minimum
        format
        items
        max_length
        maximum
        min_length
        minimum
        nullable
        pattern
        property
        validate
      ].freeze

      def all_of(*schema_names)
        wrap_error do
          schema_names.each { |name| model.add_all_of(name) }
        end
      end

      def items(**options, &block)
        wrap_error do
          raise "'items' isn't allowed for '#{model.type}'" unless model.respond_to?(:items=)

          model.items = options
          Schema.new(model.items).call(&block) if block.present?
        end
      end

      def property(name, **options, &block)
        wrap_error "'#{name}'" do
          raise "'property' isn't allowed for '#{model.type}'" unless model.respond_to?(:add_property)

          property_model = model.add_property(name, **options)
          Property.new(property_model).call(&block) if block.present?
        end
      end

      def validate(&block)
        model.add_validator(Validators::LambdaValidator.new(block))
      end
    end
  end
end
