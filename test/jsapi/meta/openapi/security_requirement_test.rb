# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class SecurityRequirementTest < Minitest::Test
        def test_add_scheme_without_scopes
          security_requirement = SecurityRequirement.new
          security_requirement.add_scheme('foo')
          assert_equal([], security_requirement.schemes['foo'].scopes)
        end

        def test_add_scheme_with_scopes
          security_requirement = SecurityRequirement.new
          security_requirement.add_scheme('foo', scopes: %w[read:foo])
          assert_equal(%w[read:foo], security_requirement.schemes['foo'].scopes)
        end

        def test_add_scheme_raises_an_exception_if_name_is_blank
          error = assert_raises(ArgumentError) do
            SecurityRequirement.new.add_scheme('')
          end
          assert_equal("name can't be blank", error.message)
        end

        def test_add_scope
          scheme = SecurityRequirement.new.add_scheme('foo')
          scheme.add_scope('read:foo')
          assert_equal(%w[read:foo], scheme.scopes)
        end

        def test_add_scope_raises_an_exception_if_scope_is_blank
          error = assert_raises(ArgumentError) do
            SecurityRequirement.new.add_scheme('foo').add_scope('')
          end
          assert_equal("scope can't be blank", error.message)
        end

        def test_empty_security_requirement_object
          assert_equal({}, SecurityRequirement.new.to_h)
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
            security_requirement.to_h
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
            security_requirement.to_h
          )
        end
      end
    end
  end
end
