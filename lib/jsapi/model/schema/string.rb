# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class String < Base
        FORMATS = %w[date date-time].freeze

        attr_reader :format, :max_length, :min_length, :pattern

        def initialize(**options)
          super(**options.merge(type: 'string'))
        end

        def format=(format)
          raise ArgumentError, "format not supported: '#{format}'" unless format.in?(FORMATS)
          raise 'format already defined' if instance_variable_defined?(:@format)

          @format = format
        end

        def max_length=(max_length)
          set_json_schema_validation(:max_length, max_length)
        end

        def min_length=(min_length)
          set_json_schema_validation(:min_length, min_length)
        end

        def pattern=(pattern)
          set_json_schema_validation(:pattern, pattern)
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
