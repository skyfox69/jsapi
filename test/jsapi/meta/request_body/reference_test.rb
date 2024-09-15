# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module RequestBody
      class ReferenceTest < Minitest::Test
        def test_resolve
          definitions = Definitions.new
          request_body = definitions.add_request_body('foo')

          request_body_reference = Reference.new(ref: 'foo')
          assert_equal(request_body, request_body_reference.resolve(definitions))
        end

        # OpenAPI objects

        def test_openapi_reference_object
          request_body_reference = Reference.new(ref: 'foo')
          assert_equal(
            { '$ref': '#/components/requestBodies/foo' },
            request_body_reference.to_openapi('3.0')
          )
        end
      end
    end
  end
end
