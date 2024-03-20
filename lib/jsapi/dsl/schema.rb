# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define reusable schemas.
    class Schema < Node
      def all_of(*schema_names)
        schema_names.each { |name| _meta_model.add_all_of(name) }
      end

      def example(example)
        _meta_model.add_example(example)
      end

      # Overrides Kernel#format.
      def format(format)
        method_missing(:format, format)
      end

      def items(**options, &block)
        unless _meta_model.respond_to?(:items=)
          raise Error, "'items' isn't allowed for '#{_meta_model.type}'"
        end

        _meta_model.items = options
        Schema.new(_meta_model.items).call(&block) if block
      end

      def model(klass = nil, &block)
        unless _meta_model.respond_to?(:model=)
          raise Error, "'model' isn't allowed for '#{_meta_model.type}'"
        end

        if block
          klass = Class.new(klass || Model::Base)
          klass.class_eval(&block)
        end
        _meta_model.model = klass
      end

      def property(name, **options, &block)
        wrap_error "'#{name}'" do
          unless _meta_model.respond_to?(:add_property)
            raise Error, "'property' isn't allowed for '#{_meta_model.type}'"
          end

          property_model = _meta_model.add_property(name, **options)
          Property.new(property_model).call(&block) if block
        end
      end
    end
  end
end
