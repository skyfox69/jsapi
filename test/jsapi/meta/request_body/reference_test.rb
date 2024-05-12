# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module RequestBody
      class ReferenceTest < Minitest::Test
        def test_resolve
          definitions = Definitions.new
          request_body = definitions.add_request_body('foo')

          reference = Reference.new(ref: 'foo')
          assert_equal(request_body, reference.resolve(definitions))
        end

        def test_resolve_raises_an_exception_on_unresolvable_name
          assert_raises(ReferenceError) do
            Reference.new(ref: 'foo').resolve(Definitions.new)
          end
        end

        # OpenAPI tests

        def test_openapi_reference_object
          reference = Reference.new(ref: 'foo')
          assert_equal(
            { '$ref': '#/components/requestBodies/foo' },
            reference.to_openapi('3.0')
          )
        end
      end
    end
  end
end
