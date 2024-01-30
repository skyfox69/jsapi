# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class ReferenceTest < Minitest::Test
        def test_resolve
          api_definitions = Definitions.new
          schema = api_definitions.add_schema('foo')

          schema_ref = Reference.new('foo')
          assert_equal(schema, schema_ref.resolve(api_definitions))
        end

        def test_json_schema
          schema_ref = Reference.new('foo')
          assert_equal(
            { '$ref': '#/definitions/foo' },
            schema_ref.to_json_schema
          )
        end

        def test_openapi_schema
          schema_ref = Reference.new('foo')
          assert_equal(
            { '$ref': '#/components/schemas/foo' },
            schema_ref.to_openapi_schema
          )
        end
      end
    end
  end
end
