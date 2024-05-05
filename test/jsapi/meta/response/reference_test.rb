# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Response
      class ReferenceTest < Minitest::Test
        def test_resolve
          response = definitions.add_response('Foo')
          reference = Reference.new(ref: 'Foo')
          assert_equal(response, reference.resolve(definitions))
        end

        def test_resolve_raises_an_exception_on_unresolvable_name
          assert_raises(ReferenceError) do
            Reference.new(ref: 'foo').resolve(Definitions.new)
          end
        end

        # OpenAPI tests

        def test_openapi_response
          reference = Reference.new(ref: 'foo')

          # OpenAPI 2.0
          assert_equal(
            { '$ref': '#/responses/foo' },
            reference.to_openapi_response('2.0')
          )
          # OpenAPI 3.0 tests
          assert_equal(
            { '$ref': '#/components/responses/foo' },
            reference.to_openapi_response('3.0')
          )
        end

        private

        def definitions
          @definitions ||= Definitions.new
        end
      end
    end
  end
end
