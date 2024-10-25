# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module RequestBody
      class ReferenceTest < Minitest::Test
        def test_component_type
          assert_equal('request_body', Reference.component_type)
        end

        def test_resolve
          definitions = Definitions.new
          request_body = definitions.add_request_body('foo')

          reference = Reference.new(ref: 'foo')
          assert_equal(request_body, reference.resolve(definitions))
        end

        # OpenAPI objects

        def test_openapi_reference_object
          assert_equal(
            { '$ref': '#/components/requestBodies/foo' },
            Reference.new(ref: 'foo').to_openapi('3.0')
          )
        end
      end
    end
  end
end
