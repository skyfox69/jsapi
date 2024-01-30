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
          schema.to_openapi_schema[:allOf]
        )
      end

      # Items tests

      def test_items
        schema = Model::Schema.new(type: 'array')
        Schema.new(schema).call { items type: 'string' }

        assert_equal(
          {
            type: 'array',
            items: {
              type: 'string'
            }
          },
          schema.to_openapi_schema
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
            properties: {
              'my_property' => {
                type: 'string'
              }
            },
            required: []
          },
          schema.to_openapi_schema
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
        schema = Model::Schema.new(type: 'integer')
        Schema.new(schema).call do
          validate do
            errors.add(:invalid) if odd?
          end
        end

        i = DOM::Integer.new(2, schema)
        schema.validate(i)
        assert_predicate(i, :valid?)

        i = DOM::Integer.new(1, schema)
        schema.validate(i)
        assert_predicate(i, :invalid?)
      end
    end
  end
end
