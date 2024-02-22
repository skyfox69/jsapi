# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class String < Base
        FORMATS = %w[date date-time].freeze

        attr_reader :format

        json_schema_validation :max_length, :min_length, :pattern

        def initialize(**options)
          super(**options.merge(type: 'string'))
        end

        def format=(format)
          raise ArgumentError, "format not supported: '#{format}'" unless format.in?(FORMATS)
          raise 'format already defined' if instance_variable_defined?(:@format)

          @format = format
        end

        private

        def json_schema_options
          super.merge(
            format: format,
            minLength: min_length,
            maxLength: max_length,
            pattern: pattern&.source
          ).compact
        end
      end
    end
  end
end
