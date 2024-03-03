# frozen_string_literal: true

module Jsapi
  module Controller
    class ResponseTest < Minitest::Test
      include DSL
      include Methods

      # Serialization tests

      def test_serialization_on_boolean
        schema = Model::Schema.new(type: 'boolean')
        response = Response.new(true, schema, api_definitions)
        assert_equal('true', response.to_json)
      end

      def test_serialization_on_integer
        schema = Model::Schema.new(type: 'integer')
        response = Response.new(1.0, schema, api_definitions)
        assert_equal('1', response.to_json)
      end

      def test_serialization_on_converted_integer
        schema = Model::Schema.new(type: 'integer', conversion: :abs)
        response = Response.new(-1.0, schema, api_definitions)
        assert_equal('1', response.to_json)
      end

      def test_serialization_on_number
        schema = Model::Schema.new(type: 'number')
        response = Response.new(1, schema, api_definitions)
        assert_equal('1.0', response.to_json)
      end

      def test_serialization_on_converted_number
        schema = Model::Schema.new(type: 'number', conversion: :abs)
        response = Response.new(-1, schema, api_definitions)
        assert_equal('1.0', response.to_json)
      end

      # Strings

      def test_serialization_on_string
        schema = Model::Schema.new(type: 'string')
        response = Response.new('Foo', schema, api_definitions)
        assert_equal('"Foo"', response.to_json)
      end

      def test_serialization_on_converted_string
        schema = Model::Schema.new(type: 'string', conversion: :upcase)
        response = Response.new('Foo', schema, api_definitions)
        assert_equal('"FOO"', response.to_json)
      end

      def test_serialization_on_date_formatted_string
        schema = Model::Schema.new(type: 'string', format: 'date')
        response = Response.new('2099-12-31T23:59:59+00:00', schema, api_definitions)
        assert_equal('"2099-12-31"', response.to_json)
      end

      def test_serialization_on_datetime_formatted_string
        schema = Model::Schema.new(type: 'string', format: 'date-time')
        response = Response.new('2099-12-31', schema, api_definitions)
        assert_equal('"2099-12-31T00:00:00.000+00:00"', response.to_json)
      end

      # Arrays

      def test_serialization_on_array
        schema = Model::Schema.new(type: 'array', items: { type: 'string' })
        response = Response.new(%w[Foo Bar], schema, api_definitions)

        assert_equal('["Foo","Bar"]', response.to_json)
      end

      def test_serialization_on_empty_array
        schema = Model::Schema.new(type: 'array', items: { type: 'string' })
        response = Response.new([], schema, api_definitions)

        assert_equal('[]', response.to_json)
      end

      def test_serialization_on_nullable_array
        schema = Model::Schema.new(type: 'array', items: { type: 'string' })
        response = Response.new(nil, schema, api_definitions)

        assert_equal('null', response.to_json)
      end

      # Object serialization tests

      def test_serialization_on_object
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        object = Object.new
        object.define_singleton_method(:foo) { 'bar' }

        response = Response.new(object, schema, api_definitions)

        assert_equal('{"foo":"bar"}', response.to_json)
      end

      def test_source
        schema = Model::Schema.new(type: 'object')
        schema.add_property(:foo, type: 'string', source: :bar)

        object = Object.new
        object.define_singleton_method(:foo) { 'foo' }
        object.define_singleton_method(:bar) { 'bar' }

        response = Response.new(object, schema, api_definitions)

        assert_equal('{"foo":"bar"}', response.to_json)
      end

      def test_serialization_on_empty_object
        schema = Model::Schema.new(type: 'object')
        response = Response.new({}, schema, api_definitions)

        assert_equal('null', response.to_json)
      end

      def test_serialization_on_nullable_object
        schema = Model::Schema.new(type: 'object')
        response = Response.new(nil, schema, api_definitions)

        assert_equal('null', response.to_json)
      end

      # Serialization error tests

      def test_serialization_error
        schema = Model::Schema.new(type: 'string', existence: true)

        error = assert_raises RuntimeError do
          Response.new(nil, schema, api_definitions).to_json
        end
        assert_equal("response can't be nil", error.message)
      end

      def test_serialization_error_on_object
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string', existence: true)

        object = Object.new
        object.define_singleton_method(:foo) { nil }

        error = assert_raises RuntimeError do
          Response.new(object, schema, api_definitions).to_json
        end
        assert_equal("foo can't be nil", error.message)
      end

      def test_serialization_error_on_nested_object
        schema = Model::Schema.new(type: 'object')
        nested_schema = schema.add_property(:foo, type: 'object').schema
        nested_schema.add_property(:bar, type: 'string', existence: true)

        nested = Object.new
        nested.define_singleton_method(:bar) { nil }

        object = Object.new
        object.define_singleton_method(:foo) { nested }

        error = assert_raises RuntimeError do
          Response.new(object, schema, api_definitions).to_json
        end
        assert_equal("foo.bar can't be nil", error.message)
      end
    end
  end
end
