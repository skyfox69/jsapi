# frozen_string_literal: true

module Jsapi
  module Controller
    class ResponseTest < Minitest::Test
      include DSL
      include Methods

      # Serialization tests

      def test_serialization_on_string
        schema = Model::Schema.new(type: 'string')
        response = Response.new('My string', schema, api_definitions)

        assert_equal('"My string"', response.to_json)
      end

      def test_serialization_on_integer
        schema = Model::Schema.new(type: 'integer')
        response = Response.new(1.0, schema, api_definitions)

        assert_equal('1', response.to_json)
      end

      def test_serialization_on_number
        schema = Model::Schema.new(type: 'number')
        response = Response.new(1, schema, api_definitions)

        assert_equal('1.0', response.to_json)
      end

      # Array serialization tests

      def test_serialization_on_array
        schema = Model::Schema.new(type: 'array', items: { type: 'string' })
        response = Response.new(%w[My string], schema, api_definitions)

        assert_equal('["My","string"]', response.to_json)
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
        schema.add_property(:my_property, type: 'string')

        object = Object.new
        object.define_singleton_method(:my_property) { 'My property value' }

        response = Response.new(object, schema, api_definitions)

        assert_equal('{"my_property":"My property value"}', response.to_json)
      end

      def test_source
        schema = Model::Schema.new(type: 'object')
        schema.add_property(:my_property, type: 'string', source: :my_source)

        object = Object.new
        object.define_singleton_method(:my_source) { 'My source value' }
        object.define_singleton_method(:my_property) { 'My property value' }

        response = Response.new(object, schema, api_definitions)

        assert_equal('{"my_property":"My source value"}', response.to_json)
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
        schema.add_property(:my_property, type: 'string', existence: true)

        object = Object.new
        object.define_singleton_method(:my_property) { nil }

        error = assert_raises RuntimeError do
          Response.new(object, schema, api_definitions).to_json
        end
        assert_equal("my_property can't be nil", error.message)
      end

      def test_serialization_error_on_nested_object
        schema = Model::Schema.new(type: 'object')
        nested_schema = schema.add_property(:nested, type: 'object').schema
        nested_schema.add_property(:property, type: 'string', existence: true)

        nested = Object.new
        nested.define_singleton_method(:property) { nil }

        object = Object.new
        object.define_singleton_method(:nested) { nested }

        error = assert_raises RuntimeError do
          Response.new(object, schema, api_definitions).to_json
        end
        assert_equal("nested.property can't be nil", error.message)
      end
    end
  end
end
