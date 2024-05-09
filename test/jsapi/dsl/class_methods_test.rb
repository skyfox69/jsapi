# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DSL
    class ClassMethodsTest < Minitest::Test
      def test_api_include
        foo_class = Class.new do
          extend ClassMethods
          api_schema 'Foo'
        end
        bar_class = Class.new do
          extend ClassMethods
          api_include foo_class
        end
        definitions = bar_class.api_definitions
        assert_predicate(definitions.schema('Foo'), :present?)
      end

      def test_api_operation
        foo_class = Class.new do
          extend ClassMethods
          api_operation 'foo'
        end
        definitions = foo_class.api_definitions
        assert_predicate(definitions.operation('foo'), :present?)
      end

      def test_api_parameter
        foo_class = Class.new do
          extend ClassMethods
          api_parameter 'foo'
        end
        definitions = foo_class.api_definitions
        assert_predicate(definitions.parameter('foo'), :present?)
      end

      def test_api_request_body
        foo_class = Class.new do
          extend ClassMethods
          api_request_body 'foo'
        end
        definitions = foo_class.api_definitions
        assert_predicate(definitions.request_body('foo'), :present?)
      end

      def test_api_rescue_from
        foo_class = Class.new do
          extend ClassMethods
          api_rescue_from StandardError
        end
        definitions = foo_class.api_definitions
        rescue_handler = definitions.rescue_handler_for(StandardError.new)
        assert_predicate(rescue_handler, :present?)
      end

      def test_api_response
        foo_class = Class.new do
          extend ClassMethods
          api_response 'Foo'
        end
        definitions = foo_class.api_definitions
        assert_predicate(definitions.response('Foo'), :present?)
      end

      def test_api_schema
        foo_class = Class.new do
          extend ClassMethods
          api_schema 'Foo'
        end
        definitions = foo_class.api_definitions
        assert_predicate(definitions.schema('Foo'), :present?)
      end

      def test_openapi
        foo_class = Class.new do
          extend ClassMethods
          openapi do
            info title: 'Foo', version: '1'
          end
        end
        assert_equal(
          { title: 'Foo', version: '1' },
          foo_class.api_definitions.openapi_document('2.0')[:info]
        )
      end
    end
  end
end
