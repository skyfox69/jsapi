# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class ParametersTest < Minitest::Test
      # Initialization tests

      def test_initialize_on_scalar_parameter
        operation.add_parameter('foo', type: 'string')
        parameters = parameters(foo: 'foo')
        assert_equal('foo', parameters['foo'])
      end

      def test_initialize_on_object_parameter
        definitions.add_schema('Foo').add_property('foo', type: 'string')

        parameter = operation.add_parameter('bar', type: 'object')
        parameter.schema.add_all_of('Foo')
        parameter.schema.add_property('bar', type: 'string')

        attributes = { 'foo' => 'foo', 'bar' => 'bar' }
        parameters = parameters(bar: attributes)
        assert_equal(attributes, parameters['bar'].attributes)
      end

      def test_initialize_on_request_body
        definitions.add_schema('Foo').add_property('foo', type: 'string')

        request_body = operation.set_request_body(type: 'object')
        request_body.schema.add_all_of('Foo')
        request_body.schema.add_property('bar', type: 'string')

        parameters = parameters(foo: 'foo', bar: 'bar')
        assert_equal('foo', parameters['foo'])
        assert_equal('bar', parameters['bar'])
      end

      # Attribute reader tests

      def test_bracket_operator
        operation.add_parameter('foo', type: 'integer')
        assert_equal(1, parameters(foo: 1)['foo'])
      end

      def test_bracket_operator_on_nil
        assert_nil(parameters[nil])
      end

      def test_attr_reader
        operation.add_parameter('foo', type: 'integer')
        assert_equal(1, parameters(foo: 1).foo)
      end

      def test_attr_reader_on_invalid_name
        assert_raises(NoMethodError) { parameters.foo }
      end

      def test_respond_to
        operation.add_parameter('foo')
        assert(parameters.respond_to?(:foo))
      end

      def test_respond_to_on_invalid_name
        assert(!parameters.respond_to?(:foo))
      end

      # Validation tests

      def test_validation
        operation.add_parameter('foo', type: 'integer', minimum: 1)
        assert_predicate(parameters(foo: 1), :valid?)
        assert_predicate(parameters(foo: 0), :invalid?)
      end

      private

      def definitions
        @definitions ||= Model::Definitions.new
      end

      def operation
        @operation ||= definitions.add_operation('operation')
      end

      def parameters(**args)
        params = ActionController::Parameters.new(**args)
        Parameters.new(params, operation, definitions)
      end
    end
  end
end
