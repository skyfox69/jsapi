# frozen_string_literal: true

module Jsapi
  module DSL
    class Schema < Node
      COMMON_METHODS = %i[
        all_of
        default
        enum
        format
        items
        max_length
        maximum
        min_length
        minimum
        pattern
        property
        validate
      ].freeze

      def all_of(*schema_names)
        wrap_error do
          schema_names.each { |name| model.add_all_of(name) }
        end
      end

      def example(example)
        wrap_error { model.add_example(example) }
      end

      def format(format)
        # Override Kernel#format
        method_missing(:format, format)
      end

      def items(**options, &block)
        wrap_error do
          unless model.respond_to?(:items=)
            raise "'items' isn't allowed for '#{model.type}'"
          end

          model.items = options
          Schema.new(model.items).call(&block) if block.present?
        end
      end

      def property(name, **options, &block)
        wrap_error "'#{name}'" do
          unless model.respond_to?(:add_property)
            raise "'property' isn't allowed for '#{model.type}'"
          end

          property_model = model.add_property(name, **options)
          Property.new(property_model).call(&block) if block.present?
        end
      end

      def validate(&block)
        wrap_error { model.add_lambda_validation(block) }
      end
    end
  end
end
