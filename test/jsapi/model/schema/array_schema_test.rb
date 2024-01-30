# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class ArraySchemaTest < Minitest::Test
        %w[json openapi].each do |name|
          define_method("test_minimal_#{name}_schema") do
            schema = ArraySchema.new
            assert_equal({ type: 'array', items: {} }, schema.to_json_schema)
          end

          define_method("test_#{name}_schema") do
            schema = ArraySchema.new(items: { type: 'string' })
            assert_equal(
              {
                type: 'array',
                items: {
                  type: 'string'
                }
              },
              schema.public_send("to_#{name}_schema")
            )
          end
        end
      end
    end
  end
end
