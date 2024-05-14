# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Response
      class ReferenceTest < Minitest::Test
        def test_resolve
          definitions = Definitions.new
          response = definitions.add_response('foo')

          response_reference = Reference.new(ref: 'foo')
          assert_equal(response, response_reference.resolve(definitions))
        end

        # OpenAPI tests

        def test_openapi_reference_object
          response_reference = Reference.new(ref: 'foo')

          # OpenAPI 2.0
          assert_equal(
            { '$ref': '#/responses/foo' },
            response_reference.to_openapi('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            { '$ref': '#/components/responses/foo' },
            response_reference.to_openapi('3.0')
          )
        end
      end
    end
  end
end
