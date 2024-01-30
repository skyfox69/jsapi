# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class ObjectSchemaTest < Minitest::Test
        def test_properties
          api_definitions = Definitions.new

          base_schema = api_definitions.add_schema('base_schema')
          base_schema.add_property('foo', type: 'string')

          schema = ObjectSchema.new
          schema.add_all_of('base_schema')
          schema.add_property('bar', type: 'integer')

          properties = schema.properties(api_definitions)
          assert_equal(%w[foo bar], properties.keys)
        end

        %w[json openapi].each do |name|
          define_method("test_minimal_#{name}_schema") do
            schema = ObjectSchema.new
            assert_equal(
              {
                type: 'object',
                properties: {},
                required: []
              },
              schema.public_send("to_#{name}_schema")
            )
          end

          define_method("test_#{name}_schema") do
            schema = ObjectSchema.new
            schema.add_property('foo', type: 'string', required: true)
            schema.add_property('bar', type: 'integer')

            assert_equal(
              {
                type: 'object',
                properties: {
                  'foo' => {
                    type: 'string'
                  },
                  'bar' => {
                    type: 'integer'
                  }
                },
                required: %w[foo]
              },
              schema.public_send("to_#{name}_schema")
            )
          end
        end
      end
    end
  end
end
