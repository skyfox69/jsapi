# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class String < Base
        include Conversion

        ##
        # :attr: format
        # The optional format of a string. Possible values are:
        #
        # - <code>"date"</code>
        # - <code>"date-time"</code>
        #
        attribute :format, ::String, values: %w[date date-time]

        ##
        # :attr: max_length
        # The maximum length of a string.
        attribute :max_length, writer: false

        ##
        # :attr: min_length
        # The minimum length of a string.
        attribute :min_length, writer: false

        ##
        # :attr: pattern
        # The regular expression a string must match.
        attribute :pattern, writer: false

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

        def to_openapi_schema(*) # :nodoc:
          format ? super.merge(format: format) : super
        end
      end
    end
  end
end
