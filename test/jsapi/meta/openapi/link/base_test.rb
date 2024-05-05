# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module Link
        class BaseTest < Minitest::Test
          def test_empty_link_object
            assert_equal({}, Base.new.to_openapi)
          end

          def test_full_link_object
            link = Base.new(
              operation_id: 'foo',
              description: 'Description of foo',
              request_body: 'bar',
              server: {
                url: 'https://foo.bar/foo'
              }
            )
            link.add_parameter(:bar, nil)

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
                }
              },
              link.to_openapi
            )
          end
        end
      end
    end
  end
end
