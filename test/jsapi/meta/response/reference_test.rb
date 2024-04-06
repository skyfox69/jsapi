# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Response
      class ReferenceTest < Minitest::Test
        def test_resolve
          response = definitions.add_response('Foo')
          reference = Reference.new('Foo')
          assert_equal(response, reference.resolve(definitions))
        end

        def test_raises_exception_on_invalid_reference
          assert_raises(ReferenceError) do
            Reference.new('foo').resolve(Definitions.new)
          end
        end

        # OpenAPI 2.0 tests

        def test_openapi_2_0_response
          reference = Reference.new('foo')
          assert_equal(
            { '$ref': '#/responses/foo' },
            reference.to_openapi_response('2.0')
          )
        end

        # OpenAPI 3.0 tests

        def test_openapi_3_0_response
          reference = Reference.new('Foo')
          assert_equal(
            { '$ref': '#/components/responses/Foo' },
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
