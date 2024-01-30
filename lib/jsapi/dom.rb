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
      def wrap(object, schema)
        object = schema.default if object.nil?
        return Null.new(schema) if object.nil?

        case schema.type
        when 'array'
          Array
        when 'boolean'
          Boolean
        when 'integer'
          Integer
        when 'number'
          Number
        when 'object'
          Object
        when 'string'
          String
        end&.new(object, schema)
      end
    end
  end
end
