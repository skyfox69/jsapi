# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class String < Base
        include Conversion

        ##
        # :attr: format
        # The format of a string.
        attribute :format, ::String

        ##
        # :attr: max_length
        # The maximum length of a string.
        attribute :max_length

        ##
        # :attr: min_length
        # The minimum length of a string.
        attribute :min_length

        ##
        # :attr: pattern
        # The regular expression a string must match.
        attribute :pattern

        undef max_length=, min_length=, pattern=

        def max_length=(value) # :nodoc:
          add_validation('max_length', Validation::MaxLength.new(value))
          @max_length = value
        end

        def min_length=(value) # :nodoc:
          add_validation('min_length', Validation::MinLength.new(value))
          @min_length = value
        end

        def pattern=(value) # :nodoc:
          add_validation('pattern', Validation::Pattern.new(value))
          @pattern = value
        end

        def to_json_schema # :nodoc:
          format ? super.merge(format: format) : super
        end

        def to_openapi(*) # :nodoc:
          format ? super.merge(format: format) : super
        end
      end
    end
  end
end
