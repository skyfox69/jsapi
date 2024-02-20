# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DSL
    class ClassMethodsTest < Minitest::Test
      class Foo
        extend ClassMethods

        api_parameter 'my_parameter'
        api_schema 'my_schema'
      end

      class Bar
        extend ClassMethods

        api_include Foo
        api_operation 'my_operation'

        openapi do
          base_path '/api'
        end
      end

      def test_api_include
        included_schema = Bar.api_definitions.schema('my_schema')
        assert_predicate(included_schema, :present?)
      end

      def test_api_operation
        assert_equal(%w[my_operation], Bar.api_definitions.operations.keys)
      end

      def test_api_parameter
        assert_equal(%w[my_parameter], Foo.api_definitions.parameters.keys)
      end

      def test_api_schema
        assert_equal(%w[my_schema], Foo.api_definitions.schemas.keys)
      end

      def test_openapi
        assert_equal('/api', Bar.api_definitions.openapi_root['base_path'])
      end
    end
  end
end
