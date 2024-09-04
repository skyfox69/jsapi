# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class PropertyTest < Minitest::Test
      def test_initialize
        property = Property.new('foo', type: 'string')
        assert_equal('foo', property.name)
        assert_equal('string', property.type)
      end

      def test_raises_exception_on_blank_name
        error = assert_raises(ArgumentError) { Property.new('') }
        assert_equal("property name can't be blank", error.message)
      end

      def test_method_chain
        property = Property.new('foo_bar')
        assert_equal(%i[foo_bar], property.method_chain.methods)

        property = Property.new('fooBar')
        assert_equal(%i[foo_bar], property.method_chain.methods)

        property = Property.new('foo', source: 'bar')
        assert_equal(%i[bar], property.method_chain.methods)
      end

      # Predicate methods tests

      def test_required_predicate
        property = Property.new('foo', existence: true)
        assert(property.required?)

        property = Property.new('foo', existence: false)
        assert(!property.required?)
      end

      # OpenAPI tests

      def test_openapi_schema_object_on_read_only
        property = Property.new(
          'foo',
          type: 'string',
          existence: true,
          read_only: true
        )
        %w[2.0 3.0].each do |version|
          assert_equal(
            { type: 'string', readOnly: true },
            property.to_openapi(version)
          )
        end
      end

      def test_openapi_schema_object_on_write_only
        property = Property.new(
          'foo',
          type: 'string',
          existence: true,
          write_only: true
        )
        # OpenAPI 2.0
        assert_equal(
          { type: 'string' },
          property.to_openapi('2.0')
        )
        # OpenAPI 3.0
        assert_equal(
          { type: 'string', writeOnly: true },
          property.to_openapi('3.0')
        )
      end
    end
  end
end
