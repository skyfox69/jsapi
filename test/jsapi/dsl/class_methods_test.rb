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
          openapi('2.0') { info name: 'Foo', version: '1' }
        end
        assert_equal(
          { name: 'Foo', version: '1' },
          foo_class.api_definitions.openapi_document('2.0')[:info]
        )
      end
    end
  end
end
