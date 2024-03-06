# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Meta
    module Schema
      module Validation
        class PatternTest < Minitest::Test
          def test_raises_error_on_invalid_pattern
            error = assert_raises(ArgumentError) { Pattern.new(nil) }
            assert_equal('invalid pattern: ', error.message)
          end

          def test_validates_pattern
            pattern = Pattern.new(/fo/)

            pattern.validate(dummy = Dummy.new('foo'))
            assert_predicate(dummy.errors, :none?)

            pattern.validate(dummy = Dummy.new('bar'))
            assert_equal(['is invalid'], dummy.errors.map(&:message))
          end

          def test_to_json_schema_validation
            assert_equal(
              { pattern: 'foo\.bar' },
              Pattern.new(/foo\.bar/).to_json_schema_validation
            )
          end

          def test_to_openapi_validation
            assert_equal(
              { pattern: 'foo\.bar' },
              Pattern.new(/foo\.bar/).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
