# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DSL
    class ClassMethodsTest < Minitest::Test
      def test_api_default
        definitions = Class.new do
          extend ClassMethods
          api_default 'array', within_responses: []
        end.api_definitions

        default = definitions.default('array')
        assert_predicate(default, :present?)
        assert_equal([], default.within_responses)
      end

      def test_api_include
        foo_class = Class.new do
          extend ClassMethods
          api_schema 'foo'
        end
        bar_class = Class.new do
          extend ClassMethods
          api_include foo_class
        end
        definitions = bar_class.api_definitions
        assert_predicate(definitions.schema('foo'), :present?)
      end

      def test_api_on_rescue
        definitions = Class.new do
          extend ClassMethods
          api_on_rescue :foo
        end.api_definitions

        assert_equal(:foo, definitions.on_rescue_callbacks.first)
      end

      def test_api_on_rescue_with_block
        definitions = Class.new do
          extend ClassMethods
          api_on_rescue { |e| e }
        end.api_definitions

        assert_instance_of(Proc, definitions.on_rescue_callbacks.first)
      end

      def test_api_operation
        definitions = Class.new do
          extend ClassMethods
          api_operation 'foo'
        end.api_definitions

        assert_predicate(definitions.operation('foo'), :present?)
      end

      def test_api_parameter
        definitions = Class.new do
          extend ClassMethods
          api_parameter 'foo'
        end.api_definitions

        assert_predicate(definitions.parameter('foo'), :present?)
      end

      def test_api_request_body
        definitions = Class.new do
          extend ClassMethods
          api_request_body 'foo'
        end.api_definitions

        assert_predicate(definitions.request_body('foo'), :present?)
      end

      def test_api_rescue_from
        definitions = Class.new do
          extend ClassMethods
          api_rescue_from StandardError
        end.api_definitions

        rescue_handler = definitions.rescue_handler_for(StandardError.new)
        assert_predicate(rescue_handler, :present?)
      end

      def test_api_response
        definitions = Class.new do
          extend ClassMethods
          api_response 'foo'
        end.api_definitions

        assert_predicate(definitions.response('foo'), :present?)
      end

      def test_api_schema
        definitions = Class.new do
          extend ClassMethods
          api_schema 'foo'
        end.api_definitions

        assert_predicate(definitions.schema('foo'), :present?)
      end

      def test_openapi
        definitions = Class.new do
          extend ClassMethods
          openapi do
            info title: 'foo', version: '1'
          end
        end.api_definitions

        assert_equal(
          {
            swagger: '2.0',
            info: {
              title: 'foo',
              version: '1'
            }
          },
          definitions.openapi_document('2.0')
        )
      end
    end
  end
end
