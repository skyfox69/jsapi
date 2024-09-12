# frozen_string_literal: true

require_relative 'schema/additional_properties'
require_relative 'schema/conversion'
require_relative 'schema/boundary'
require_relative 'schema/delegator'
require_relative 'schema/discriminator'
require_relative 'schema/reference'
require_relative 'schema/validation'

require_relative 'schema/base'
require_relative 'schema/array'
require_relative 'schema/boolean'
require_relative 'schema/numeric'
require_relative 'schema/integer'
require_relative 'schema/number'
require_relative 'schema/object'
require_relative 'schema/string'

module Jsapi
  module Meta
    module Schema
      TYPES = %w[array boolean integer number object string].freeze # :nodoc:

      TYPES.each do |type|
        Base.define_method("#{type}?") { self.type == type }
      end

      class << self
        # Creates a new schema model or reference. The +:type+ keyword determines
        # the type of the schema to be created. Possible types are:
        #
        # - <code>"array"</code>
        # - <code>"boolean"</code>
        # - <code>"integer"</code>
        # - <code>"number"</code>
        # - <code>"object"</code>
        # - <code>"string"</code>
        #
        # The default type is <code>"object"</code>.
        #
        # Raises an InvalidArgumentError if the given type is invalid.
        def new(keywords = {})
          return Reference.new(keywords) if keywords.key?(:ref)

          type = keywords[:type]
          case type&.to_s
          when 'array'
            Array
          when 'boolean'
            Boolean
          when 'integer'
            Integer
          when 'number'
            Number
          when 'object', nil
            Object
          when 'string'
            String
          else
            raise InvalidArgumentError.new('type', type, valid_values: TYPES)
          end.new(keywords.except(:type))
        end
      end
    end
  end
end
