# frozen_string_literal: true

require_relative 'schema/base'
require_relative 'schema/array_schema'
require_relative 'schema/numeric_schema'
require_relative 'schema/object_schema'
require_relative 'schema/reference'
require_relative 'schema/string_schema'

module Jsapi
  module Model
    module Schema
      class << self
        def new(**options)
          ref = options[:$ref]
          return Reference.new(ref) if ref.present?

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
            raise ArgumentError, "Invalid type: '#{type}'"
          end.new(**options.except(:$ref))
        end
      end
    end
  end
end
