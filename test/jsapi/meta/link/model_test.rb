# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Link
      class ModelTest < Minitest::Test
        def test_empty_openapi_link_object
          assert_equal({}, Model.new.to_openapi)
        end

        def test_full_openapi_link_object
          link_model = Model.new(
            operation_id: 'foo',
            parameters: {
              'bar' => nil
            },
            request_body: 'bar',
            description: 'Lorem ipsum',
            server: {
              url: 'https://foo.bar/foo'
            },
            openapi_extensions: { 'foo' => 'bar' }
          )
          assert_equal(
            {
              operationId: 'foo',
              parameters: {
                'bar' => nil
              },
              requestBody: 'bar',
              description: 'Lorem ipsum',
              server: {
                url: 'https://foo.bar/foo'
              },
              'x-foo': 'bar'
            },
            link_model.to_openapi
          )
        end
      end
    end
  end
end
