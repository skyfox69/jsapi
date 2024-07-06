# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module Link
        class ModelTest < Minitest::Test
          def test_empty_link_object
            assert_equal({}, Model.new.to_openapi)
          end

          def test_full_link_object
            link_model = Model.new(
              operation_id: 'foo',
              description: 'Description of foo',
              request_body: 'bar',
              server: {
                url: 'https://foo.bar/foo'
              }
            )
            link_model.add_parameter(:bar, nil)
            link_model.add_openapi_extension('foo', 'bar')

            assert_equal(
              {
                operationId: 'foo',
                parameters: {
                  'bar' => nil
                },
                requestBody: 'bar',
                description: 'Description of foo',
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
end
