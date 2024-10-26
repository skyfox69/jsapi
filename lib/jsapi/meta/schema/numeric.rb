# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Numeric < Base
        include Conversion

        ##
        # :attr: maximum
        # The (exclusive) maximum.
        attribute :maximum, accessors: %i[reader]

        ##
        # :attr: minimum
        # The (exclusive) minimum.
        attribute :minimum, accessors: %i[reader]

        ##
        # :attr: multiple_of
        attribute :multiple_of, accessors: %i[reader]

        def maximum=(value) # :nodoc:
          boundary = Boundary.from(value)

          add_validation(
            'maximum',
            Validation::Maximum.new(
              boundary.value,
              exclusive: boundary.exclusive?
            )
          )
          @maximum = boundary
        end

        def minimum=(value) # :nodoc:
          boundary = Boundary.from(value)

          add_validation(
            'minimum',
            Validation::Minimum.new(
              boundary.value,
              exclusive: boundary.exclusive?
            )
          )
          @minimum = boundary
        end

        def multiple_of=(value) # :nodoc:
          add_validation('multiple_of', Validation::MultipleOf.new(value))
          @multiple_of = value
        end
      end
    end
  end
end
