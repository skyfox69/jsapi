# frozen_string_literal: true

module Jsapi
  module DSL
    class SchemaTest < Minitest::Test
      def test_all_of
        schema = Meta::Schema.new
        Schema.new(schema) { all_of 'foo' }
        assert_equal(%w[foo], schema.all_of_references.map(&:schema))
      end

      def test_example
        schema = Meta::Schema.new
        Schema.new(schema) { example 'foo' }
        assert_equal(%w[foo], schema.examples)
      end

      def test_format
        schema = Meta::Schema.new(type: 'string')
        Schema.new(schema) { format 'date' }
        assert_equal('date', schema.format)
      end

      # Items tests

      def test_items
        schema = Meta::Schema.new(type: 'array')
        Schema.new(schema) { items type: 'string' }
        assert_predicate(schema.items, :string?)
      end

      def test_items_with_block
        schema = Meta::Schema.new(type: 'array')
        Schema.new(schema) do
          items type: 'string' do
            format 'date'
          end
        end
        assert_predicate(schema.items, :string?)
        assert_equal('date', schema.items.format)
      end

      def test_items_raises_an_exception_on_other_type_than_array
        schema = Meta::Schema.new(type: 'object')
        error = assert_raises Error do
          Schema.new(schema) { items type: 'string' }
        end
        assert_equal("items isn't supported for 'object'", error.message)
      end

      # Model tests

      def test_model
        foo = Class.new(Model::Base)
        schema = Meta::Schema.new(type: 'object')
        Schema.new(schema) { model foo }
        assert_equal(foo, schema.model)
      end

      def test_model_with_block
        schema = Meta::Schema.new(type: 'object')
        Schema.new(schema) do
          model do
            def foo
              'bar'
            end
          end
        end
        bar = schema.model.new({})
        assert_kind_of(Model::Base, bar)
        assert_equal('bar', bar.foo)
      end

      def test_model_with_class_and_block
        foo = Class.new(Model::Base)
        schema = Meta::Schema.new(type: 'object')
        Schema.new(schema) do
          model foo do
            def foo
              'bar'
            end
          end
        end
        bar = schema.model.new({})
        assert_kind_of(foo, bar)
        assert_equal('bar', bar.foo)
      end

      def test_model_raises_an_exception_on_other_type_than_object
        schema = Meta::Schema.new(type: 'array')
        error = assert_raises Error do
          Schema.new(schema) { model {} }
        end
        assert_equal("model isn't supported for 'array'", error.message)
      end

      # Property tests

      def test_property
        schema = Meta::Schema.new
        Schema.new(schema) do
          property 'foo', type: 'string'
        end
        property = schema.properties['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_property_with_block
        schema = Meta::Schema.new
        Schema.new(schema) do
          property 'foo', type: 'array' do
            items type: 'string'
          end
        end
        property = schema.properties['foo']
        assert_predicate(property.schema.items, :string?)
      end

      def test_property_raises_an_exception_on_other_type_than_object
        schema = Meta::Schema.new(type: 'array')
        error = assert_raises Error do
          Schema.new(schema) { property 'foo' }
        end
        assert_equal(
          "property isn't supported for 'array' (at property \"foo\")",
          error.message
        )
      end

      private

      def definitions
        Meta::Definitions.new
      end
    end
  end
end
