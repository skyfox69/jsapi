# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class StringSchema < Base
        FORMATS = %w[date date-time].freeze

        attr_reader :format, :max_length, :min_length, :pattern

        def initialize(**options)
          super(**options.merge(type: 'string')) # Override type
        end

        def format=(format)
          raise ArgumentError, "format not supported: '#{format}'" unless FORMATS.include?(format)

          @format = format
        end

        def max_length=(max_length)
          register_validator(:max_length, @max_length = max_length)
        end

        def min_length=(min_length)
          register_validator(:min_length, @min_length = min_length)
        end

        def pattern=(pattern)
          register_validator(:pattern, @pattern = pattern)
        end

        private

        def json_schema_options
          super.merge(
            format: format,
            minLength: min_length,
            maxLength: max_length,
            pattern: pattern&.source
          )
        end
      end
    end
  end
end
