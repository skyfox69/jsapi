# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a schema.
    class Schema < Node

      # Includes all of the properties from +schemas+. Each argument must
      # be the name of a schema defined by Definitions#schema.
      def all_of(*schemas)
        schemas.each { |schema| _meta_model.add_all_of(schema) }
      end

      # Specifies a sample matching the schema.
      def example(example)
        _meta_model.add_example(example)
      end

      def format(format) # :nodoc:
        # Override Kernel#format
        method_missing(:format, format)
      end

      # Specifies the kind of items that can be contained in an array.
      #
      #   items do
      #     property 'foo', type: 'string'
      #   end
      #
      # ==== Options
      #
      # [+schema+]
      #   The referred schema. The value must be the name of a schema defined
      #   by Definitions#schema. +:schema:+ cannot be specified together with
      #   +:type+, +:default+, +conversion+, +items+, and +:format+.
      # [+:type+]
      #   The type of an item. See Meta::Schema for details.
      # [+:existence+]
      #   The level of existence that must be reached by each item.
      #   See Meta::Existence for details.
      # [+:default+]
      #   The default value to replace +nil+ items by.
      # [+:conversion+]
      #   The method or +Proc+ to convert an item.
      #     items type: 'string', conversion: :upcase
      # [+:items+]
      #   The kind of items that can be contained in a nested array.
      #     items type: 'array', items: { type: 'string' }
      # [+:format+]
      #   The string format. Possible values are <code>'date'</code> and
      #   <code>'date-time'</code>. Items are implictly casted to an instance
      #   of +Date+ or +DateTime+ if format is specified.
      #     items type: 'string', format: 'date'
      #
      def items(**options, &block)
        unless _meta_model.respond_to?(:items=)
          raise Error, "'items' isn't allowed for '#{_meta_model.type}'"
        end

        _meta_model.items = options
        Schema.new(_meta_model.items).call(&block) if block
      end

      # Specifies the model class to access nested object parameters by.
      #
      #   model Foo do
      #     def bar
      #       # ...
      #     end
      #   end
      # +klass+ can be any subclass of Model::Base. If block is given, an
      # anonymous class is created that inherits either from +klass+ or
      # Model::Base.
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

      # Defines a property
      #
      #   property 'foo', type: 'string'
      #
      # ==== Options
      #
      # [+schema+]
      #   The referred schema. The value must be the name of a schema defined
      #   by Definitions#schema. +:schema+ cannot be specified together with
      #   +:type+, +:default+, +:conversion+, +:model+, +:items+, +:format+,
      #   annotations, and validations.
      # [+:type+]
      #   The type of the property. See Meta::Schema for details.
      # [+:existence+]
      #   The level of existence. See Meta::Existence for details.
      # [+:default+]
      #   The default value.
      # [+:conversion+]
      #   The method or +Proc+ to convert a property value by when accessing
      #   nested object parameters.
      #     property 'foo', type: 'string', conversion: :upcase
      # [+:source+]
      #   The method to read the property value when serializing an object.
      #     property 'foo', type: 'string', source: :bar
      # [+:model+]
      #   The model class to access deeply nested object parameters by. The
      #   default model class is Model::Base.
      # [+:items+]
      #   The kind of items that can be contained in an array.
      #     property 'foo', type: 'array', items: { type: 'string' }
      # [+:format+]
      #   The string format. Possible values are <code>'date'</code> and
      #   <code>'date-time'</code>. \Property values are implictly casted to
      #   an instance of +Date+ or +DateTime+ if format is specified.
      #     property 'foo', type: 'string', format: 'date'
      #
      # ===== Annotations
      #
      # [+description+]
      #   The description of the property.
      # [+example+]
      #   A sample property value.
      # [+deprecated+]
      #   Specifies whether or not the property is deprecated.
      #
      # ===== Validations
      #
      # Same as Operation#parameter.
      #
      def property(name, **options, &block)
        define("'#{name}'") do
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
