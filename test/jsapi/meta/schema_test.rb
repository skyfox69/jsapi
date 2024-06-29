# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class SchemaTest < Minitest::Test
      def test_new_schema
        schema = Schema.new
        assert_kind_of(Schema::Object, schema)
      end

      def test_new_array_schema
        schema = Schema.new(type: 'array')
        assert_kind_of(Schema::Array, schema)
      end

      def test_new_boolean_schema
        schema = Schema.new(type: 'boolean')
        assert_kind_of(Schema::Base, schema)
      end

      def test_new_integer_schema
        schema = Schema.new(type: 'integer')
        assert_kind_of(Schema::Numeric, schema)
      end

      def test_new_number_schema
        schema = Schema.new(type: 'number')
        assert_kind_of(Schema::Numeric, schema)
      end

      def test_new_object_schema
        schema = Schema.new(type: 'object')
        assert_kind_of(Schema::Object, schema)
      end

      def test_new_reference
        schema = Schema.new(ref: 'foo')
        assert_kind_of(Schema::Reference, schema)
      end

      def test_new_string_schema
        schema = Schema.new(type: 'string')
        assert_kind_of(Schema::String, schema)
      end

      def test_raises_exception_on_invalid_type
        error = assert_raises(InvalidArgumentError) do
          Schema.new(type: 'foo')
        end
        assert_equal(
          'type must be one of ["array", "boolean", "integer", ' \
          '"number", "object", "string"], is "foo"',
          error.message
        )
      end
    end
  end
end
