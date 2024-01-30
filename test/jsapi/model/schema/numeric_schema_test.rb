# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class NumericSchemaTest < Minitest::Test
        def test_exclusive_maximum
          schema = NumericSchema.new(type: 'integer', exclusive_maximum: 0)
          assert_equal(0, schema.exclusive_maximum)
        end

        def test_exclusive_minimum
          schema = NumericSchema.new(type: 'integer', exclusive_minimum: 0)
          assert_equal(0, schema.exclusive_minimum)
        end

        def test_maximum
          schema = NumericSchema.new(type: 'integer', maximum: 0)
          assert_equal(0, schema.maximum)
        end

        def test_minimum
          schema = NumericSchema.new(type: 'integer', minimum: 0)
          assert_equal(0, schema.minimum)
        end

        %w[json openapi].each do |name|
          define_method("test_minimal_#{name}_schema") do
            schema = NumericSchema.new(type: 'integer')
            assert_equal(
              {
                type: 'integer'
              },
              schema.public_send("to_#{name}_schema")
            )
          end

          define_method("test_#{name}_schema") do
            schema = NumericSchema.new(
              type: 'integer',
              minimum: 1,
              maximum: 2,
              exclusive_minimum: 0,
              exclusive_maximum: 3
            )
            assert_equal(
              {
                type: 'integer',
                minimum: 1,
                maximum: 2,
                exclusiveMinimum: 0,
                exclusiveMaximum: 3
              },
              schema.public_send("to_#{name}_schema")
            )
          end
        end
      end
    end
  end
end
