# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a schema.
    class Schema < Node

      # Includes all of the properties from +schemas+. Each argument must
      # be the name of a schema defined by ClassMethods#api_schema or
      # Definitions#schema.
      def all_of(*schemas)
        schemas.each { |schema| _meta_model.add_all_of({ schema: schema }) }
      end

      # Specifies a sample matching the schema.
      def example(example)
        _meta_model.add_example(example)
      end

      # Overrides Kernel#format
      def format(format) # :nodoc:
        method_missing(:format, format)
      end

      # Specifies the kind of items that can be contained in an array.
      #
      #   items do
      #     property 'foo', type: 'string'
      #   end
      def items(**keywords, &block)
        unless _meta_model.respond_to?(:items=)
          raise Error, "items isn't supported for '#{_meta_model.type}'"
        end

        _meta_model.items = keywords
        Schema.new(_meta_model.items).call(&block) if block
      end

      # Specifies the model class to access nested object parameters by.
      #
      #   model Foo do
      #     def bar
      #       # ...
      #     end
      #   end
      #
      # +klass+ can be any subclass of Model::Base. If block is given, an
      # anonymous class is created that inherits either from +klass+ or
      # Model::Base.
      def model(klass = nil, &block)
        unless _meta_model.respond_to?(:model=)
          raise Error, "model isn't supported for '#{_meta_model.type}'"
        end

        if block
          klass = Class.new(klass || Model::Base)
          klass.class_eval(&block)
        end
        _meta_model.model = klass
      end

      # Defines a property
      #
      #   property 'foo', type: 'string'
      def property(name, **keywords, &block)
        define('property', name.inspect) do
          unless _meta_model.respond_to?(:add_property)
            raise Error, "property isn't supported for '#{_meta_model.type}'"
          end

          property_model = _meta_model.add_property(name, keywords)
          Schema.new(property_model).call(&block) if block
        end
      end
    end
  end
end
