# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class ReferenceTest < Minitest::Test
        def test_reference_by_schema
          reference = Reference.new(schema: 'foo')
          assert_equal('foo', reference.ref)
          assert_equal('foo', reference.schema)
        end

        def test_resolve
          definitions = Definitions.new
          schema = definitions.add_schema('foo')

          assert_equal(schema, Reference.new(ref: 'foo').resolve(definitions))
        end

        def test_resolve_with_higher_existence_level
          definitions = Definitions.new
          definitions.add_schema('foo', existence: :allow_empty)
          reference = Reference.new(ref: 'foo', existence: true)

          resolved = reference.resolve(definitions)
          assert_kind_of(Delegator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        def test_resolve_with_lower_existence_level
          definitions = Definitions.new
          definitions.add_schema('foo', existence: true)
          reference = Reference.new(ref: 'foo', existence: :allow_empty)

          resolved = reference.resolve(definitions)
          assert_kind_of(Delegator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        # JSON Schema tests

        def test_json_schema_reference_object
          reference = Reference.new(ref: 'foo')
          assert_equal(
            { '$ref': '#/definitions/foo' },
            reference.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_reference_object
          reference = Reference.new(ref: 'foo')

          # OpenAPI 2.0
          assert_equal(
            { '$ref': '#/definitions/foo' },
            reference.to_openapi('2.0')
          )
          # OpenAPI 3.0
          reference = Reference.new(schema: 'foo')
          assert_equal(
            { '$ref': '#/components/schemas/foo' },
            reference.to_openapi('3.0')
          )
        end
      end
    end
  end
end
