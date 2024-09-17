# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class ReferenceTest < Minitest::Test
        def test_component_type
          assert_equal('schema', Reference.component_type)
        end

        def test_resolve
          definitions = Definitions.new
          schema = definitions.add_schema('foo')

          assert_equal(schema, Reference.new(ref: 'foo').resolve(definitions))
        end

        def test_resolve_with_higher_existence_level
          definitions = Definitions.new
          definitions.add_schema('foo', existence: :allow_empty)
          schema_reference = Reference.new(ref: 'foo', existence: true)

          resolved = schema_reference.resolve(definitions)
          assert_kind_of(Delegator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        def test_resolve_with_lower_existence_level
          definitions = Definitions.new
          definitions.add_schema('foo', existence: true)
          schema_reference = Reference.new(ref: 'foo', existence: :allow_empty)

          resolved = schema_reference.resolve(definitions)
          assert_kind_of(Delegator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        # JSON Schema objects

        def test_json_schema_reference_object
          schema_reference = Reference.new(ref: 'foo')
          assert_equal(
            { '$ref': '#/definitions/foo' },
            schema_reference.to_json_schema
          )
        end

        # OpenAPI objects

        def test_openapi_reference_object
          schema_reference = Reference.new(ref: 'foo')

          # OpenAPI 2.0
          assert_equal(
            { '$ref': '#/definitions/foo' },
            schema_reference.to_openapi('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            { '$ref': '#/components/schemas/foo' },
            schema_reference.to_openapi('3.0')
          )
        end
      end
    end
  end
end
