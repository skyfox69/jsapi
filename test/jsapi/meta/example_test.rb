# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class ExampleTest < Minitest::Test
      def test_minimal_openapi_example_object
        example = Example.new(value: 'foo')

        assert_equal(
          { value: 'foo' },
          example.to_openapi_example
        )
      end

      def test_full_openapi_example_object
        example = Example.new(
          summary: 'Foo',
          description: 'Description of foo',
          value: 'foo'
        )
        assert_equal(
          {
            summary: 'Foo',
            description: 'Description of foo',
            value: 'foo'
          },
          example.to_openapi_example
        )
      end

      def test_openapi_example_object_on_external
        example = Example.new(
          value: '/foo/bar',
          external: true
        )
        assert_equal(
          { external_value: '/foo/bar' },
          example.to_openapi_example
        )
      end
    end
  end
end
