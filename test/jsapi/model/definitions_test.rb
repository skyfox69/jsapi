# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class DefinitionsTest < Minitest::Test
      class FooBarController; end

      def setup
        @api_definitions = Definitions.new(FooBarController)
      end

      # Operation tests

      def test_default_operation_name
        @api_definitions.add_operation
        assert_equal(%w[foo_bar], @api_definitions.operations.keys)
      end

      def test_add_operation
        @api_definitions.add_operation('my_operation')
        assert(@api_definitions.operations.key?('my_operation'))
      end

      def test_add_operation_on_double
        @api_definitions.add_operation('my_operation')

        error = assert_raises(RuntimeError) do
          @api_definitions.add_operation('my_operation')
        end
        assert_equal("operation already defined: 'my_operation'", error.message)
      end

      def test_operation
        @api_definitions.add_operation('my_operation')
        assert_equal('my_operation', @api_definitions.operation('my_operation').operation_id)
      end

      def test_default_operation
        @api_definitions.add_operation('my_operation')
        assert_equal('my_operation', @api_definitions.operation.operation_id)
      end

      def test_operation_on_nil
        assert_nil(@api_definitions.operation(nil))
      end

      # OpenAPI document tests

      def test_minimal_openapi_document
        assert_equal({ openapi: '3.0.3' }, @api_definitions.openapi_document)
      end
    end
  end
end
