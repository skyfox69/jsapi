# frozen_string_literal: true

module Jsapi
  module DSL
    class SchemaTest < Minitest::Test
      def test_description
        schema = Model::Schema.new
        Schema.new(schema).call { description 'Foo' }
        assert_equal('Foo', schema.description)
      end

      def test_example
        schema = Model::Schema.new
        Schema.new(schema).call { example 'foo' }
        assert_equal(%w[foo], schema.examples)
      end

      def test_format
        schema = Model::Schema.new(type: 'string')
        Schema.new(schema).call { format 'date' }
        assert_equal('date', schema.format)
      end

      def test_all_of
        schema = Model::Schema.new
        Schema.new(schema).call { all_of 'Foo' }
        assert_equal(%w[Foo], schema.all_of.map(&:reference))
      end

      # Items tests

      def test_items
        schema = Model::Schema.new(type: 'array')
        Schema.new(schema).call { items type: 'string' }
        assert_predicate(schema.items, :string?)
      end

      def test_items_with_block
        schema = Model::Schema.new(type: 'array')
        Schema.new(schema).call do
          items type: 'string' do
            format 'date'
          end
        end
        assert_equal('date', schema.items.format)
      end

      def test_items_raises_an_error_on_other_type_than_array
        schema = Model::Schema.new(type: 'object')
        error = assert_raises Error do
          Schema.new(schema).call { items type: 'string' }
        end
        assert_equal("'items' isn't allowed for 'object'", error.message)
      end

      # Property tests

      def test_property
        schema = Model::Schema.new
        Schema.new(schema).call do
          property 'foo', type: 'string'
        end
        property = schema.properties(definitions)['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_property_raises_an_error_on_other_type_than_object
        schema = Model::Schema.new(type: 'array')
        error = assert_raises Error do
          Schema.new(schema).call { property 'foo' }
        end
        assert_equal("'property' isn't allowed for 'array' (at 'foo')", error.message)
      end

      # Validate tests

      def test_validate
        schema = Model::Schema.new
        Schema.new(schema).call { validate {} }
      end

      private

      def definitions
        Model::Definitions.new
      end
    end
  end
end
