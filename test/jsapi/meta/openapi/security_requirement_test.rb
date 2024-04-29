# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class SecurityRequirementTest < Minitest::Test
        def test_empty_security_requirement_object
          assert_equal({}, SecurityRequirement.new.to_openapi)
        end

        def test_security_requirement_object_without_scopes
          security_requirement = SecurityRequirement.new
          security_requirement.add_scheme('foo')
          security_requirement.add_scheme('bar')

          assert_equal(
            {
              'foo' => [],
              'bar' => []
            },
            security_requirement.to_openapi
          )
        end

        def test_security_requirement_object_with_scopes
          security_requirement = SecurityRequirement.new
          security_requirement.add_scheme('foo', scopes: %w[read:foo])
          security_requirement.add_scheme('bar', scopes: %w[read:bar])

          assert_equal(
            {
              'foo' => %w[read:foo],
              'bar' => %w[read:bar]
            },
            security_requirement.to_openapi
          )
        end
      end
    end
  end
end
