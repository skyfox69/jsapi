# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DSL
    class ClassMethodsTest < Minitest::Test
      extend ClassMethods

      api_operation 'my_operation'
      api_parameter 'my_parameter'
      api_schema 'my_schema'

      def test_api_operation
        assert_equal %w[my_operation], api_definitions.operations.keys
      end

      def test_api_parameter
        assert_equal %w[my_parameter], api_definitions.parameters.keys
      end

      def test_api_schema
        assert_equal %w[my_schema], api_definitions.schemas.keys
      end

      private

      def api_definitions
        self.class.api_definitions
      end
    end
  end
end
