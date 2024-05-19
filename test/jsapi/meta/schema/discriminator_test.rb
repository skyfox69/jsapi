# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class DiscriminatorTest < Minitest::Test
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
          discriminator.add_mapping('foo', 'Foo')
          discriminator.add_mapping('bar', 'Bar')

          # OpenAPI 2.0
          assert_equal('type', discriminator.to_openapi('2.0'))

          # OpenAPI 3.0
          assert_equal(
            {
              propertyName: 'type',
              mapping: { 'foo' => 'Foo', 'bar' => 'Bar' }
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
