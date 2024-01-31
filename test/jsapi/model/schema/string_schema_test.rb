# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class StringSchemaTest < Minitest::Test
        def test_format
          schema = StringSchema.new(format: 'date')
          assert_equal('date', schema.format)
        end

        def test_unsupported_format
          error = assert_raises ArgumentError do
            StringSchema.new(format: 'foo')
          end
          assert_equal("format not supported: 'foo'", error.message)
        end

        def test_max_length
          schema = StringSchema.new(max_length: 10)
          assert_equal(10, schema.max_length)
        end

        def test_min_length
          schema = StringSchema.new(min_length: 10)
          assert_equal(10, schema.min_length)
        end

        def test_pattern
          schema = StringSchema.new(pattern: /$\d{4}-\d{2}-\d{2}^/)
          assert_equal('$\d{4}-\d{2}-\d{2}^', schema.pattern.source)
        end

        %w[json openapi].each do |name|
          define_method("test_minimal_#{name}_schema") do
            schema = StringSchema.new
            assert_equal(
              {
                type: 'string'
              },
              schema.public_send("to_#{name}_schema")
            )
          end

          define_method("test_#{name}_schema") do
            schema = StringSchema.new(
              format: 'date',
              min_length: 10,
              max_length: 10,
              pattern: /$\d{4}-\d{2}-\d{2}^/
            )
            assert_equal(
              {
                type: 'string',
                format: 'date',
                minLength: 10,
                maxLength: 10,
                pattern: '$\d{4}-\d{2}-\d{2}^'
              },
              schema.public_send("to_#{name}_schema")
            )
          end
        end
      end
    end
  end
end
