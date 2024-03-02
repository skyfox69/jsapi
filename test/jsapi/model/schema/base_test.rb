# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class BaseTest < Minitest::Test
        def test_raises_error_on_invalid_option
          error = assert_raises(ArgumentError) { Base.new(foo: 'bar') }
          assert_equal("invalid option: 'foo'", error.message)
        end

        def test_examples
          schema = Schema.new(type: 'string', example: 'foo')
          schema.add_example('bar')
          assert_equal(%w[foo bar], schema.examples)
        end

        def test_enum
          schema = Base.new(enum: %w[foo bar])
          enum = schema.validations['enum']

          assert_predicate(enum, :present?)
          assert_equal(%w[foo bar], enum.value)
        end

        def test_raises_error_on_double_enum
          schema = Base.new(enum: %w[foo bar])

          error = assert_raises { schema.enum = %w[foo bar] }
          assert_equal('enum already defined', error.message)
        end

        def test_existence
          schema = Base.new
          schema.existence = true
          assert_equal(Existence::PRESENT, schema.existence)
        end

        def test_default_existence
          schema = Base.new
          assert_equal(Existence::ALLOW_OMITTED, schema.existence)
        end

        def test_nullable
          schema = Base.new
          assert schema.nullable?
        end

        # JSON Schema tests

        def test_json_schema
          schema = Schema.new(
            type: 'string',
            existence: true,
            description: 'Foo',
            default: 'foo',
            example: 'bar'
          )
          assert_equal(
            {
              type: 'string',
              description: 'Foo',
              default: 'foo',
              examples: %w[bar]
            },
            schema.to_json_schema
          )
        end

        def test_json_schema_on_nullable
          schema = Schema.new(type: 'string', existence: :allow_null)
          assert_equal(
            {
              type: %w[string null]
            },
            schema.to_json_schema
          )
        end

        def test_json_schema_including_enum
          schema = Schema.new(type: 'string', enum: %w[foo bar])
          assert_equal(
            {
              type: %w[string null],
              enum: %w[foo bar]
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_2_0_schema
          schema = Schema.new(
            type: 'string',
            existence: true,
            description: 'Foo',
            default: 'foo',
            example: 'bar'
          )
          assert_equal(
            {
              type: 'string',
              description: 'Foo',
              default: 'foo',
              example: 'bar'
            },
            schema.to_openapi_schema('2.0')
          )
        end

        def test_openapi_3_0_schema
          schema = Schema.new(
            type: 'string',
            existence: true,
            description: 'Foo',
            default: 'foo',
            example: 'bar'
          )
          assert_equal(
            {
              type: 'string',
              description: 'Foo',
              default: 'foo',
              examples: %w[bar]
            },
            schema.to_openapi_schema('3.0')
          )
        end

        def test_openapi_3_0_schema_on_nullable
          schema = Schema.new(type: 'string', existence: :allow_null)
          assert_equal(
            {
              type: 'string',
              nullable: true
            },
            schema.to_openapi_schema('3.0')
          )
        end

        def test_openapi_3_0_schema_including_enum
          schema = Schema.new(type: 'string', enum: %w[foo bar])
          assert_equal(
            {
              type: 'string',
              nullable: true,
              enum: %w[foo bar]
            },
            schema.to_openapi_schema('3.0')
          )
        end

        def test_openapi_3_1_schema
          schema = Schema.new(
            type: 'string',
            existence: true,
            description: 'Foo',
            default: 'foo',
            example: 'bar'
          )
          assert_equal(
            {
              type: 'string',
              description: 'Foo',
              default: 'foo',
              examples: %w[bar]
            },
            schema.to_openapi_schema('3.1')
          )
        end

        def test_openapi_3_1_schema_on_nullable
          schema = Schema.new(type: 'string', existence: :allow_null)
          assert_equal(
            {
              type: %w[string null]
            },
            schema.to_openapi_schema('3.1')
          )
        end

        def test_raises_error_on_unsupported_openapi_version
          schema = Schema.new(type: 'string')
          error = assert_raises(ArgumentError) do
            schema.to_openapi_schema('foo')
          end
          assert_equal('unsupported OpenAPI version: foo', error.message)
        end
      end
    end
  end
end
