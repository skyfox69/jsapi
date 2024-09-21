# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class DiscriminatorTest < Minitest::Test
        # Mapping

        def test_mapping_on_string_keys
          mappings = { 'foo' => 'Foo', 'bar' => 'Bar' }
          discriminator = Discriminator.new(mappings: mappings)
          assert_equal(mappings, discriminator.mappings)
        end

        def test_mapping_on_integer_keys
          mappings = { 1 => 'Foo', 2 => 'Bar' }
          discriminator = Discriminator.new(mappings: mappings)
          assert_equal(mappings, discriminator.mappings)
        end

        def test_mapping_on_boolean_keys
          mappings = { false => 'Foo', true => 'Bar' }
          discriminator = Discriminator.new(mappings: mappings)
          assert_equal(mappings, discriminator.mappings)
        end

        # OpenAPI objects

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
          discriminator = Discriminator.new(
            property_name: 'type',
            mappings: { false => 'Foo', true => 'Bar' }
          )
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
      end
    end
  end
end
