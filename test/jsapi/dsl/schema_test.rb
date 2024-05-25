# frozen_string_literal: true

module Jsapi
  module DSL
    class SchemaTest < Minitest::Test
      def test_all_of
        schema = define_schema { all_of 'foo' }
        assert_equal(%w[foo], schema.all_of_references.map(&:schema))
      end

      def test_example
        schema = define_schema { example 'foo' }
        assert_equal(%w[foo], schema.examples)
      end

      def test_format
        schema = define_schema(type: 'string') { format 'date' }
        assert_equal('date', schema.format)
      end

      # Items tests

      def test_items
        schema = define_schema(type: 'array') { items type: 'string' }
        assert_predicate(schema.items, :string?)
      end

      def test_items_with_block
        schema = define_schema(type: 'array') do
          items type: 'string' do
            format 'date'
          end
        end
        assert_predicate(schema.items, :string?)
        assert_equal('date', schema.items.format)
      end

      def test_items_raises_an_exception_on_other_type_than_array
        error = assert_raises Error do
          define_schema(type: 'object') { items type: 'string' }
        end
        assert_equal("items isn't supported for 'object'", error.message)
      end

      # Model tests

      def test_model
        klass = Class.new(Model::Base)
        schema = define_schema(type: 'object') { model klass }
        assert_equal(klass, schema.model)
      end

      def test_model_with_block
        schema = define_schema(type: 'object') do
          model do
            def foo
              'bar'
            end
          end
        end
        model = schema.model.new({})
        assert_kind_of(Model::Base, model)
        assert_equal('bar', model.foo)
      end

      def test_model_with_class_and_block
        klass = Class.new(Model::Base)
        schema = define_schema(type: 'object') do
          model klass do
            def foo
              'bar'
            end
          end
        end
        model = schema.model.new({})
        assert_kind_of(klass, model)
        assert_equal('bar', model.foo)
      end

      def test_model_raises_an_exception_on_other_type_than_object
        error = assert_raises Error do
          define_schema(type: 'array') { model {} }
        end
        assert_equal("model isn't supported for 'array'", error.message)
      end

      # Property tests

      def test_property
        schema = define_schema(type: 'object') do
          property 'foo', type: 'string'
        end
        property = schema.property('foo')
        assert_predicate(property.schema, :string?)
      end

      def test_property_with_block
        schema = define_schema(type: 'object') do
          property 'foo', type: 'array' do
            items type: 'string'
          end
        end
        property = schema.property('foo')
        assert_predicate(property.schema.items, :string?)
      end

      def test_property_raises_an_exception_on_other_type_than_object
        error = assert_raises Error do
          define_schema(type: 'array') { property 'foo' }
        end
        assert_equal(
          "property isn't supported for 'array' (at property \"foo\")",
          error.message
        )
      end

      private

      def define_schema(**keywords, &block)
        Meta::Schema.new(keywords).tap do |schema|
          Schema.new(schema, &block)
        end
      end
    end
  end
end
