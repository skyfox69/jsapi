# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Example
      class ModelTest < Minitest::Test
        def test_minimal_openapi_example_object
          example_model = Model.new(value: 'foo')

          assert_equal(
            { value: 'foo' },
            example_model.to_openapi
          )
        end

        def test_full_openapi_example_object
          example_model = Model.new(
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
            example_model.to_openapi
          )
        end

        def test_openapi_example_object_on_external
          example_model = Model.new(
            value: '/foo/bar',
            external: true
          )
          assert_equal(
            { external_value: '/foo/bar' },
            example_model.to_openapi
          )
        end
      end
    end
  end
end
