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

      def test_serializes_a_boolean
        response_model = Meta::Response.new(type: 'boolean')
        response = Response.new(true, response_model, definitions)
        assert_equal('true', response.to_json)
      end

      def test_serializes_an_integer
        response_model = Meta::Response.new(type: 'integer')
        response = Response.new(1.0, response_model, definitions)
        assert_equal('1', response.to_json)
      end

      def test_converts_an_integer
        response_model = Meta::Response.new(type: 'integer', conversion: :abs)
        response = Response.new(-1.0, response_model, definitions)
        assert_equal('1', response.to_json)
      end

      def test_serializes_a_number
        response_model = Meta::Response.new(type: 'number')
        response = Response.new(1, response_model, definitions)
        assert_equal('1.0', response.to_json)
      end

      def test_converts_a_number
        response_model = Meta::Response.new(type: 'number', conversion: :abs)
        response = Response.new(-1, response_model, definitions)
        assert_equal('1.0', response.to_json)
      end

      # Strings

      def test_serializes_a_string
        response_model = Meta::Response.new(type: 'string')
        response = Response.new('Foo', response_model, definitions)
        assert_equal('"Foo"', response.to_json)
      end

      def test_serializes_a_string_on_date_format
        response_model = Meta::Response.new(type: 'string', format: 'date')
        response = Response.new('2099-12-31T23:59:59+00:00', response_model, definitions)
        assert_equal('"2099-12-31"', response.to_json)
      end

      def test_serializes_a_string_on_datetime_format
        response_model = Meta::Response.new(type: 'string', format: 'date-time')
        response = Response.new('2099-12-31', response_model, definitions)
        assert_equal('"2099-12-31T00:00:00.000+00:00"', response.to_json)
      end

      def test_serializes_a_string_on_duration_format
        response_model = Meta::Response.new(type: 'string', format: 'duration')
        duration = ActiveSupport::Duration.build(86_400)
        response = Response.new(duration, response_model, definitions)
        assert_equal('"P1D"', response.to_json)
      end

      def test_converts_a_string
        response_model = Meta::Response.new(type: 'string', conversion: :upcase)
        response = Response.new('Foo', response_model, definitions)
        assert_equal('"FOO"', response.to_json)
      end

      # Arrays

      def test_serializes_an_array
        response_model = Meta::Response.new(type: 'array', items: { type: 'string' })
        response = Response.new(%w[Foo Bar], response_model, definitions)
        assert_equal('["Foo","Bar"]', response.to_json)
      end

      def test_serializes_an_empty_array
        response_model = Meta::Response.new(type: 'array', items: { type: 'string' })
        response = Response.new([], response_model, definitions)
        assert_equal('[]', response.to_json)
      end

      def test_serializes_a_nullable_array
        response_model = Meta::Response.new(type: 'array', items: { type: 'string' })
        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)
      end

      # Objects

      def test_serializes_an_object
        response_model = Meta::Response.new(type: 'object')
        response_model.schema.add_property('foo', type: 'string')

        dummy_class = Struct.new(:foo, keyword_init: true)
        dummy = dummy_class.new(foo: 'bar')

        response = Response.new(dummy, response_model, definitions)
        assert_equal('{"foo":"bar"}', response.to_json)
      end

      def test_reads_a_property_value_by_source
        response_model = Meta::Response.new(type: 'object')
        response_model.schema.add_property('foo', type: 'string', source: :bar)

        dummy_class = Struct.new(:bar, keyword_init: true)
        dummy = dummy_class.new(bar: 'bar')

        response = Response.new(dummy, response_model, definitions)
        assert_equal('{"foo":"bar"}', response.to_json)
      end

      def test_converts_camel_case_to_snake_case
        response_model = Meta::Response.new(type: 'object')
        response_model.schema.add_property('fooBar', type: 'string')

        dummy_class = Struct.new(:foo_bar, keyword_init: true)
        dummy = dummy_class.new(foo_bar: 'foo')

        response = Response.new(dummy, response_model, definitions)
        assert_equal('{"fooBar":"foo"}', response.to_json)
      end

      def test_serializes_an_object_with_additional_properties
        response_model = Meta::Response.new(
          type: 'object',
          additional_properties: { type: 'string' }
        )
        response_model.schema.add_property('foo', type: 'string')

        dummy_class = Struct.new(:additional_properties, :foo, keyword_init: true)
        dummy = dummy_class.new(foo: 'bar', additional_properties: { foo: 'foo', bar: 'foo' })

        response = Response.new(dummy, response_model, definitions)
        assert_equal('{"foo":"bar","bar":"foo"}', response.to_json)

        dummy = dummy_class.new(foo: 'bar', additional_properties: nil)

        response = Response.new(dummy, response_model, definitions)
        assert_equal('{"foo":"bar"}', response.to_json)
      end

      def test_reads_additional_properties_by_source
        response_model = Meta::Response.new(
          type: 'object',
          additional_properties: { type: 'string', source: :foo }
        )
        dummy_class = Struct.new(:foo, keyword_init: true)
        dummy = dummy_class.new(foo: { foo: 'bar', bar: 'foo' })

        response = Response.new(dummy, response_model, definitions)
        assert_equal('{"foo":"bar","bar":"foo"}', response.to_json)
      end

      def test_serializes_an_object_on_polymorphism
        definitions
          .add_schema('base', discriminator: { property_name: 'type' })
          .add_property('type', type: 'string')

        definitions
          .add_schema('foo', all_of: [{ ref: 'base' }])
          .add_property('foo', type: 'string')

        definitions
          .add_schema('bar', all_of: [{ ref: 'base' }])
          .add_property('bar', type: 'string')

        response_model = Meta::Response.new(schema: 'base')

        foo_class = Struct.new(:type, :foo, keyword_init: true)
        foo = foo_class.new(type: 'foo', foo: 'bar')

        response = Response.new(foo, response_model, definitions)
        assert_equal('{"type":"foo","foo":"bar"}', response.to_json)

        bar_class = Struct.new(:type, :bar, keyword_init: true)
        bar = bar_class.new(type: 'bar', bar: 'foo')

        response = Response.new(bar, response_model, definitions)
        assert_equal('{"type":"bar","bar":"foo"}', response.to_json)
      end

      def test_serializes_an_empty_object
        response_model = Meta::Response.new(type: 'object')
        response = Response.new({}, response_model, definitions)
        assert_equal('null', response.to_json)
      end

      def test_serializes_null
        response_model = Meta::Response.new(type: 'object')
        response = Response.new(nil, response_model, definitions)
        assert_equal('null', response.to_json)
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
          Response.new(Struct.new(:foo).new, response_model, definitions).to_json
        end
        assert_equal("foo can't be nil", error.message)
      end

      def test_raises_exception_on_invalid_nested_object
        response_model = Meta::Response.new(type: 'object')
        nested_schema = response_model.schema.add_property('foo', type: 'object').schema
        nested_schema.add_property(:bar, type: 'string', existence: true)

        dummy_class = Struct.new(:foo, keyword_init: true)
        dummy = dummy_class.new(foo: Struct.new(:bar).new)

        error = assert_raises RuntimeError do
          Response.new(dummy, response_model, definitions).to_json
        end
        assert_equal("foo.bar can't be nil", error.message)
      end

      def test_raises_exception_on_invalid_additional_property
        response_model = Meta::Response.new(
          type: 'object',
          additional_properties: { type: 'string', existence: true }
        )
        dummy_class = Struct.new(:additional_properties, keyword_init: true)
        dummy = dummy_class.new(additional_properties: { foo: nil })

        error = assert_raises RuntimeError do
          Response.new(dummy, response_model, definitions).to_json
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
        dummy_class = Struct.new(:foo, keyword_init: true)
        nested_class = Struct.new(:additional_properties, keyword_init: true)
        dummy = dummy_class.new(foo: nested_class.new(additional_properties: { bar: nil }))

        error = assert_raises RuntimeError do
          Response.new(dummy, response_model, definitions).to_json
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
