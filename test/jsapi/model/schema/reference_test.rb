# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
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
          assert_kind_of(Decorator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        def test_resolve_with_lower_existence_level
          definitions = Definitions.new
          definitions.add_schema('foo', existence: true)
          reference = Reference.new(schema: 'foo', existence: :allow_empty)

          resolved = reference.resolve(definitions)
          assert_kind_of(Decorator, resolved)
          assert_equal(Existence::PRESENT, resolved.existence)
        end

        # JSON Schema and OpenAPI tests

        def test_json_schema
          reference = Reference.new(schema: 'foo')
          assert_equal(
            { '$ref': '#/definitions/foo' },
            reference.to_json_schema
          )
        end

        def test_openapi_schema
          reference = Reference.new(schema: 'foo')
          assert_equal(
            { '$ref': '#/components/schemas/foo' },
            reference.to_openapi_schema
          )
        end
      end
    end
  end
end
