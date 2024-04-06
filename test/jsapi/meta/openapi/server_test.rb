# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ServerTest < Minitest::Test
        def test_empty_server_object
          assert_equal({}, Server.new.to_h)
        end

        def test_full_server_object
          server = Server.new(
            description: 'Foo',
            url: 'https://{subdomain}.foo.bar'
          )
          server.add_variable('subdomain', { default: 'api' })

          assert_equal(
            {
              description: 'Foo',
              url: 'https://{subdomain}.foo.bar',
              variables: {
                'subdomain' => {
                  default: 'api'
                }
              }
            },
            server.to_h
          )
        end
      end
    end
  end
end
