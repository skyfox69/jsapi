# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Numeric < Base
        include Conversion

        def maximum=(value_or_options)
          if value_or_options.is_a?(Hash)
            value = value_or_options[:value]
            exclusive = value_or_options[:exclusive] == true
          else
            value = value_or_options
            exclusive = false
          end
          add_validation('maximum', Validation::Maximum.new(value, exclusive: exclusive))
        end

        def minimum=(value_or_options)
          if value_or_options.is_a?(Hash)
            value = value_or_options[:value]
            exclusive = value_or_options[:exclusive] == true
          else
            value = value_or_options
            exclusive = false
          end
          add_validation('minimum', Validation::Minimum.new(value, exclusive: exclusive))
        end

        def multiple_of=(value)
          add_validation('multiple_of', Validation::MultipleOf.new(value))
        end
      end
    end
  end
end
