# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class ReferenceTest < Minitest::Test
        def test_existence
          reference = Reference.new(schema: 'foo')
          reference.existence = true
          assert_equal(Existence::PRESENT, reference.existence)
        end

        def test_default_existence
          schema = Reference.new(schema: 'foo')
          assert_equal(Existence::ALLOW_OMITTED, schema.existence)
        end

        # #resolve tests

        def test_resolve
          definitions = Definitions.new
          schema = definitions.add_schema('foo')

          assert_equal(schema, Reference.new(schema: 'foo').resolve(definitions))
        end

        def test_resolve_recursively
          definitions = Definitions.new
          schema = definitions.add_schema('foo')
          definitions.add_schema('foo_ref', schema: 'foo')

          assert_equal(schema, Reference.new(schema: 'foo_ref').resolve(definitions))
        end

        def test_resolve_with_higher_existence_level
          definitions = Definitions.new
          definitions.add_schema('foo', existence: :allow_empty)
          reference = Reference.new(schema: 'foo', existence: true)

          resolved = reference.resolve(definitions)
          assert_kind_of(Delegator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        def test_resolve_with_lower_existence_level
          definitions = Definitions.new
          definitions.add_schema('foo', existence: true)
          reference = Reference.new(schema: 'foo', existence: :allow_empty)

          resolved = reference.resolve(definitions)
          assert_kind_of(Delegator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        def test_raises_error_on_invalid_reference
          assert_raises(ReferenceError) do
            Reference.new(schema: 'foo').resolve(Definitions.new)
          end
        end

        # JSON Schema tests

        def test_json_schema
          reference = Reference.new(schema: 'foo')
          assert_equal(
            { '$ref': '#/definitions/foo' },
            reference.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_schema_2_0
          reference = Reference.new(schema: 'foo')
          assert_equal(
            { '$ref': '#/definitions/foo' },
            reference.to_openapi_schema('2.0')
          )
        end

        def test_openapi_schema_3_0
          reference = Reference.new(schema: 'foo')
          assert_equal(
            { '$ref': '#/components/schemas/foo' },
            reference.to_openapi_schema('3.0')
          )
        end
      end
    end
  end
end
