# frozen_string_literal: true

module Jsapi
  module DSL
    class Schema < Node
      def all_of(*schema_names)
        wrap_error do
          schema_names.each { |name| _meta_model.add_all_of(name) }
        end
      end

      def example(example)
        wrap_error { _meta_model.add_example(example) }
      end

      def format(format)
        # Override Kernel#format
        method_missing(:format, format)
      end

      def items(**options, &block)
        wrap_error do
          unless _meta_model.respond_to?(:items=)
            raise "'items' isn't allowed for '#{_meta_model.type}'"
          end

          _meta_model.items = options
          Schema.new(_meta_model.items).call(&block) if block.present?
        end
      end

      def property(name, **options, &block)
        wrap_error "'#{name}'" do
          unless _meta_model.respond_to?(:add_property)
            raise "'property' isn't allowed for '#{_meta_model.type}'"
          end

          property_model = _meta_model.add_property(name, **options)
          Property.new(property_model).call(&block) if block.present?
        end
      end

      def validate(&block)
        wrap_error { _meta_model.add_lambda_validation(block) }
      end
    end
  end
end
