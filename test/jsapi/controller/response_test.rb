# frozen_string_literal: true

module Jsapi
  module Controller
    class ResponseTest < Minitest::Test
      def test_inspect
        response_model = Meta::Response.new(type: 'string')
        response = Response.new('foo', response_model, definitions)
        assert_equal('#<Jsapi::Controller::Response "foo">', response.inspect)
      end

      # Serialization tests

      def test_serializes_booleans
        response_model = Meta::Response.new(type: 'boolean')

        response = Response.new(true, response_model, definitions)
        assert_equal('true', response.to_json)

        response = Response.new(false, response_model, definitions)
        assert_equal('false', response.to_json)

        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)
      end

      def test_serializes_integers
        response_model = Meta::Response.new(type: 'integer')

        response = Response.new(1, response_model, definitions)
        assert_equal('1', response.to_json)

        response = Response.new(1.0, response_model, definitions)
        assert_equal('1', response.to_json)

        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)
      end

      def test_converts_integers
        response_model = Meta::Response.new(type: 'integer', conversion: :abs)

        response = Response.new(-1.0, response_model, definitions)
        assert_equal('1', response.to_json)
      end

      def test_serializes_numbers
        response_model = Meta::Response.new(type: 'number')

        response = Response.new(1.0, response_model, definitions)
        assert_equal('1.0', response.to_json)

        response = Response.new(1, response_model, definitions)
        assert_equal('1.0', response.to_json)

        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)
      end

      def test_converts_numbers
        response_model = Meta::Response.new(type: 'number', conversion: :abs)

        response = Response.new(-1, response_model, definitions)
        assert_equal('1.0', response.to_json)
      end

      # Strings

      def test_serializes_strings
        response_model = Meta::Response.new(type: 'string')

        response = Response.new('foo', response_model, definitions)
        assert_equal('"foo"', response.to_json)

        response = Response.new('', response_model, definitions)
        assert_equal('""', response.to_json)

        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)

        definitions.add_default('string', within_responses: '')
        assert_equal('""', response.to_json)
      end

      def test_serializes_strings_on_date_format
        response_model = Meta::Response.new(type: 'string', format: 'date')

        response = Response.new('2099-12-31T23:59:59+00:00', response_model, definitions)
        assert_equal('"2099-12-31"', response.to_json)
      end

      def test_serializes_strings_on_datetime_format
        response_model = Meta::Response.new(type: 'string', format: 'date-time')

        response = Response.new('2099-12-31', response_model, definitions)
        assert_equal('"2099-12-31T00:00:00.000+00:00"', response.to_json)
      end

      def test_serializes_strings_on_duration_format
        response_model = Meta::Response.new(type: 'string', format: 'duration')

        duration = ActiveSupport::Duration.build(86_400)
        response = Response.new(duration, response_model, definitions)
        assert_equal('"P1D"', response.to_json)
      end

      def test_converts_strings
        response_model = Meta::Response.new(type: 'string', conversion: :upcase)

        response = Response.new('Foo', response_model, definitions)
        assert_equal('"FOO"', response.to_json)
      end

      # Arrays

      def test_serializes_arrays
        response_model = Meta::Response.new(type: 'array', items: { type: 'string' })

        response = Response.new(%w[foo bar], response_model, definitions)
        assert_equal('["foo","bar"]', response.to_json)

        response = Response.new([], response_model, definitions)
        assert_equal('[]', response.to_json)

        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)

        definitions.add_default('array', within_responses: [])
        assert_equal('[]', response.to_json)
      end

      # Objects

      def test_serializes_objects
        response_model = Meta::Response.new(type: 'object')
        response_model.schema.add_property('foo', type: 'string')

        response = Response.new({ foo: 'bar' }, response_model, definitions)
        assert_equal('{"foo":"bar"}', response.to_json)

        response = Response.new({}, response_model, definitions)
        assert_equal('{"foo":null}', response.to_json)

        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)

        definitions.add_default('object', within_responses: {})
        assert_equal('{"foo":null}', response.to_json)
      end

      def test_serializes_objects_with_additional_properties
        response_model = Meta::Response.new(
          type: 'object',
          additional_properties: { type: 'string' }
        )
        response = Response.new(
          {
            additional_properties: {
              foo: 'bar',
              bar: 'foo'
            }
          },
          response_model,
          definitions
        )
        assert_equal('{"foo":"bar","bar":"foo"}', response.to_json)

        response = Response.new({}, response_model, definitions)
        assert_equal('null', response.to_json)
      end

      def test_serializes_objects_with_fixed_and_additional_properties
        response_model = Meta::Response.new(
          type: 'object',
          additional_properties: { type: 'string' }
        )
        response_model.schema.add_property('foo', type: 'string')

        response = Response.new(
          {
            foo: 'bar',
            additional_properties: {
              foo: 'foo',
              bar: 'foo'
            }
          },
          response_model,
          definitions
        )
        assert_equal('{"foo":"bar","bar":"foo"}', response.to_json)

        response = Response.new({ foo: 'bar' }, response_model, definitions)
        assert_equal('{"foo":"bar"}', response.to_json)
      end

      def test_serializes_objects_on_polymorphism
        definitions
          .add_schema('base', discriminator: { property_name: 'type' })
          .add_property('type', type: 'string', default: 'foo')

        definitions
          .add_schema('foo', all_of: [{ ref: 'base' }])
          .add_property('foo', type: 'string')

        definitions
          .add_schema('bar', all_of: [{ ref: 'base' }])
          .add_property('bar', type: 'string')

        response_model = Meta::Response.new(schema: 'base')

        response = Response.new({ foo: 'bar' }, response_model, definitions)
        assert_equal('{"type":"foo","foo":"bar"}', response.to_json)

        response = Response.new({ type: 'bar', bar: 'foo' }, response_model, definitions)
        assert_equal('{"type":"bar","bar":"foo"}', response.to_json)
      end

      # Serialization error tests

      def test_raises_exception_on_invalid_response
        response_model = Meta::Response.new(type: 'string', existence: true)

        error = assert_raises RuntimeError do
          Response.new(nil, response_model, definitions).to_json
        end
        assert_equal("response can't be nil", error.message)
      end

      def test_raises_exception_on_invalid_object
        response_model = Meta::Response.new(type: 'object')
        response_model.schema.add_property('foo', type: 'string', existence: true)

        error = assert_raises RuntimeError do
          Response.new({ foo: nil }, response_model, definitions).to_json
        end
        assert_equal("foo can't be nil", error.message)
      end

      def test_raises_exception_on_invalid_nested_object
        response_model = Meta::Response.new(type: 'object')
        nested_schema = response_model.schema.add_property('foo', type: 'object').schema
        nested_schema.add_property(:bar, type: 'string', existence: true)

        error = assert_raises RuntimeError do
          Response.new({ foo: { bar: nil } }, response_model, definitions).to_json
        end
        assert_equal("foo.bar can't be nil", error.message)
      end

      def test_raises_exception_on_invalid_additional_property
        response_model = Meta::Response.new(
          type: 'object',
          additional_properties: { type: 'string', existence: true }
        )
        error = assert_raises RuntimeError do
          Response.new(
            { additional_properties: { foo: nil } },
            response_model,
            definitions
          ).to_json
        end
        assert_equal("foo can't be nil", error.message)
      end

      def test_raises_exception_on_invalid_nested_additional_property
        response_model = Meta::Response.new(type: 'object')
        response_model.add_property(
          'foo',
          type: 'object',
          additional_properties: { type: 'string', existence: true }
        )
        error = assert_raises RuntimeError do
          Response.new(
            { foo: { additional_properties: { bar: nil } } },
            response_model,
            definitions
          ).to_json
        end
        assert_equal("foo.bar can't be nil", error.message)
      end

      # I18n tests

      def test_i18n
        object = Object.new
        object.define_singleton_method(:foo) { I18n.t(:hello_world) }

        response_model = Meta::Response.new(type: 'object')
        response_model.schema.add_property('foo', type: 'string')
        response = Response.new(object, response_model, definitions)
        assert_equal('{"foo":"Hello world"}', response.to_json)

        response_model = Meta::Response.new(type: 'object', locale: :de)
        response_model.schema.add_property('foo', type: 'string')
        response = Response.new(object, response_model, definitions)
        assert_equal('{"foo":"Hallo Welt"}', response.to_json)
      end

      private

      def definitions
        @definitions ||= Meta::Definitions.new
      end
    end
  end
end
