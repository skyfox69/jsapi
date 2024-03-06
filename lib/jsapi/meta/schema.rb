# frozen_string_literal: true

require_relative 'schema/conversion'
require_relative 'schema/decorator'
require_relative 'schema/reference'
require_relative 'schema/base'
require_relative 'schema/array'
require_relative 'schema/numeric'
require_relative 'schema/object'
require_relative 'schema/string'
require_relative 'schema/validation'

module Jsapi
  module Meta
    module Schema
      class << self
        def new(**options)
          return Reference.new(**options) if options.key?(:schema)

          case type = options[:type]&.to_s
          when 'array'
            Array
          when 'boolean'
            Base
          when 'integer', 'number'
            Numeric
          when 'object', nil
            Object
          when 'string'
            String
          else
            raise ArgumentError, "invalid type: '#{type}'"
          end.new(**options)
        end
      end
    end
  end
end
