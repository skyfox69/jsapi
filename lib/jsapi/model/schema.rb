# frozen_string_literal: true

require_relative 'schema/existence_attribute'
require_relative 'schema/reference'
require_relative 'schema/base'
require_relative 'schema/array_schema'
require_relative 'schema/numeric_schema'
require_relative 'schema/object_schema'
require_relative 'schema/string_schema'

module Jsapi
  module Model
    module Schema
      class << self
        def new(**options)
          return Reference.new(options[:schema], existence: options[:existence]) if options.key?(:schema)

          case type = options[:type]&.to_s
          when 'array'
            ArraySchema
          when 'boolean'
            Base
          when 'integer', 'number'
            NumericSchema
          when 'object', nil
            ObjectSchema
          when 'string'
            StringSchema
          else
            raise ArgumentError, "invalid type: '#{type}'"
          end.new(**options)
        end
      end
    end
  end
end
