# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class String < Base
        FORMATS = %w[date date-time].freeze

        attr_reader :format

        include Conversion

        def initialize(**options)
          super(**options.merge(type: 'string'))
        end

        def format=(format)
          raise ArgumentError, "format not supported: '#{format}'" unless format.in?(FORMATS)
          raise 'format already defined' if instance_variable_defined?(:@format)

          @format = format
        end

        def max_length=(value)
          add_validation('max_length', Validation::MaxLength.new(value))
        end

        def min_length=(value)
          add_validation('min_length', Validation::MinLength.new(value))
        end

        def pattern=(value)
          add_validation('pattern', Validation::Pattern.new(value))
        end

        def to_json_schema(definitions = nil)
          format ? super.merge(format: format) : super
        end

        def to_openapi_schema(_version)
          format ? super.merge(format: format) : super
        end
      end
    end
  end
end
