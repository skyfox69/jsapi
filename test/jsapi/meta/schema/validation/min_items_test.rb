# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Meta
    module Schema
      module Validation
        class MinItemsTest < Minitest::Test
          def test_raises_error_on_invalid_min_length
            error = assert_raises(ArgumentError) { MinItems.new(nil) }
            assert_equal('invalid min items: ', error.message)
          end

          def test_validates_min_items
            min_items = MinItems.new(2)

            errors = Model::Errors.new
            assert(min_items.validate(%w[foo bar], errors))
            assert_predicate(errors, :empty?)

            errors = Model::Errors.new
            assert(!min_items.validate(%w[foo], errors))
            assert(errors.added?(:base, 'is invalid'))
          end

          def test_to_json_schema_validation
            assert_equal(
              { minItems: 2 },
              MinItems.new(2).to_json_schema_validation
            )
          end

          def test_to_openapi_validation
            assert_equal(
              { minItems: 2 },
              MinItems.new(2).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
