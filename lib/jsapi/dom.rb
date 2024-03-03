# frozen_string_literal: true

require_relative 'dom/base_object'
require_relative 'dom/array'
require_relative 'dom/boolean'
require_relative 'dom/integer'
require_relative 'dom/null'
require_relative 'dom/number'
require_relative 'dom/object'
require_relative 'dom/string'

module Jsapi
  module DOM
    class << self
      def wrap(object, schema, definitions = nil)
        schema = schema.resolve(definitions) unless definitions.nil?

        object = schema.default if object.nil?
        return Null.new(schema) if object.nil?

        case schema.type
        when 'array'
          Array.new(object, schema, definitions)
        when 'boolean'
          Boolean.new(object, schema)
        when 'integer'
          Integer.new(object, schema)
        when 'number'
          Number.new(object, schema)
        when 'object'
          Object.new(object, schema, definitions)
        when 'string'
          String.new(object, schema)
        else
          raise "invalid type: #{schema.type}"
        end
      end
    end
  end
end
