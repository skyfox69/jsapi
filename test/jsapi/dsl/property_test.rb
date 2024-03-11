# frozen_string_literal: true

module Jsapi
  module DSL
    class PropertyTest < Minitest::Test
      def test_description
        property = Meta::Property.new('property', type: 'string')
        Property.new(property).call { description 'Foo' }
        assert_equal('Foo', property.schema.description)
      end

      def test_example
        property = Meta::Property.new('property', type: 'string')
        Property.new(property).call { example 'foo' }
        assert_equal(%w[foo], property.schema.examples)
      end

      def test_deprecated
        property = Meta::Property.new('property')
        Property.new(property).call { deprecated true }
        assert(property.deprecated?)
      end

      def test_delegates_to_schema
        property = Meta::Property.new('property', type: 'string')
        Property.new(property).call { format 'date' }
        assert_equal('date', property.schema.format)
      end
    end
  end
end
