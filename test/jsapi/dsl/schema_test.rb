# frozen_string_literal: true

module Jsapi
  module DSL
    class SchemaTest < Minitest::Test
      def test_description
        schema = Model::Schema.new
        Schema.new(schema).call { description 'My description' }
        assert_equal('My description', schema.description)
      end

      def test_all_of
        schema = Model::Schema.new
        Schema.new(schema).call { all_of :my_schema }

        assert_equal(
          [
            { '$ref': '#/components/schemas/my_schema' }
          ],
          schema.to_openapi_schema('3.0.3')[:allOf]
        )
      end

      # Items tests

      def test_items
        schema = Model::Schema.new(type: 'array')
        Schema.new(schema).call { items type: 'string' }

        assert_equal(
          {
            type: 'array',
            nullable: true,
            items: {
              type: 'string',
              nullable: true
            }
          },
          schema.to_openapi_schema('3.0.3')
        )
      end

      def test_items_on_other_type_than_array
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
          property 'my_property', type: 'string'
        end

        assert_equal(
          {
            type: 'object',
            nullable: true,
            properties: {
              'my_property' => {
                type: 'string',
                nullable: true
              }
            },
            required: []
          },
          schema.to_openapi_schema('3.0.3')
        )
      end

      def test_property_on_other_type_than_object
        schema = Model::Schema.new(type: 'array')
        error = assert_raises Error do
          Schema.new(schema).call { property 'my_property' }
        end
        assert_equal("'property' isn't allowed for 'array' (at 'my_property')", error.message)
      end

      # Validate tests

      def test_validate
        schema = Model::Schema.new
        Schema.new(schema).call { validate {} }
        assert_predicate(schema.validators, :one?)
      end
    end
  end
end
