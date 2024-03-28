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

        parameters = parameters(bar: { 'foo' => 'FOO', 'bar' => 'BAR' })
        assert_equal('FOO', parameters['bar'].foo)
        assert_equal('BAR', parameters['bar'].bar)
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

      # Attributes tests

      def test_bracket_operator
        operation.add_parameter('foo', type: 'string')
        assert_equal('bar', parameters(foo: 'bar')['foo'])
        assert_nil(parameters[nil])
      end

      def test_attribute_predicate
        operation.add_parameter('foo', type: 'string')
        parameters = parameters(foo: nil)

        assert(parameters.attribute?(:foo))
        assert(!parameters.attribute?(:bar))
        assert(!parameters.attribute?(nil))
      end

      def test_attributes
        operation.add_parameter('foo', type: 'string')
        parameters = parameters(foo: 'bar')
        assert_equal({ 'foo' => 'bar' }, parameters.attributes)
      end

      # Validation tests

      def test_validates_parameters_against_schema
        operation.add_parameter('foo', type: 'string', existence: true)

        errors = Model::Errors.new
        assert(parameters(foo: 'bar').validate(errors))
        assert_predicate(errors, :empty?)

        errors = Model::Errors.new
        assert(!parameters(foo: '').validate(errors))
        assert(errors.added?(:foo, "can't be blank"))
      end

      def test_validates_nested_parameters_against_model
        parameter = operation.add_parameter('foo', type: 'object')
        parameter.schema.add_property('bar', type: 'string', existence: true)

        errors = Model::Errors.new
        assert(parameters(foo: { 'bar' => 'Bar' }).validate(errors))
        assert_predicate(errors, :empty?)

        errors = Model::Errors.new
        assert(!parameters(foo: {}).validate(errors))
        assert(errors.added?(:foo, "'bar' can't be blank"))
      end

      # inspect

      def test_inspect
        operation.add_parameter('foo', type: 'string')
        assert_equal(
          '#<Jsapi::Controller::Parameters foo: "bar">',
          parameters(foo: 'bar').inspect
        )
      end

      private

      def definitions
        @definitions ||= Meta::Definitions.new
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
