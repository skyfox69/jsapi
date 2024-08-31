# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class DiscriminatorTest < Minitest::Test
        # mapping

        def test_mapping_on_string_keys
          discriminator = Discriminator.new
          discriminator.add_mapping('foo', 'Foo')
          discriminator.add_mapping('bar', 'Bar')

          assert_equal({ 'foo' => 'Foo', 'bar' => 'Bar' }, discriminator.mappings)
        end

        def test_mapping_on_integer_keys
          discriminator = Discriminator.new
          discriminator.add_mapping(1, 'Foo')
          discriminator.add_mapping(2, 'Bar')

          assert_equal({ 1 => 'Foo', 2 => 'Bar' }, discriminator.mappings)
        end

        def test_mapping_on_boolean_keys
          discriminator = Discriminator.new
          discriminator.add_mapping(false, 'Foo')
          discriminator.add_mapping(true, 'Bar')

          assert_equal({ false => 'Foo', true => 'Bar' }, discriminator.mappings)
        end

        # resolve

        def test_resolve
          schema = definitions.add_schema('Foo', type: 'object')

          discriminator = Discriminator.new
          assert(schema.equal?(discriminator.resolve('Foo', definitions)))
        end

        def test_resolve_on_mapping
          schema = definitions.add_schema('Foo', type: 'object')

          discriminator = Discriminator.new
          discriminator.add_mapping('foo', 'Foo')

          assert(schema.equal?(discriminator.resolve('foo', definitions)))
        end

        def test_resolve_raises_an_error_on
          discriminator = Discriminator.new
          error = assert_raises(RuntimeError) do
            discriminator.resolve('foo', definitions)
          end
          assert_equal('inherriting schema not found: "foo"', error.message)
        end

        # OpenAPI tests

        def test_minimal_openapi_discriminator_object
          discriminator = Discriminator.new(property_name: 'type')

          # OpenAPI 2.0
          assert_equal('type', discriminator.to_openapi('2.0'))

          # OpenAPI 3.0
          assert_equal(
            { propertyName: 'type' },
            discriminator.to_openapi('3.0')
          )
        end

        def test_full_openapi_discriminator_object
          discriminator = Discriminator.new(property_name: 'type')
          discriminator.add_mapping(false, 'Foo')
          discriminator.add_mapping(true, 'Bar')

          # OpenAPI 2.0
          assert_equal('type', discriminator.to_openapi('2.0'))

          # OpenAPI 3.0
          assert_equal(
            {
              propertyName: 'type',
              mapping: { 'false' => 'Foo', 'true' => 'Bar' }
            },
            discriminator.to_openapi('3.0')
          )
        end

        private

        def definitions
          @definitions ||= Definitions.new
        end
      end
    end
  end
end
