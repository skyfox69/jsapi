# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      # Used by Reference to delegate method calls to the referred schema.
      class Delegator
        # The level of Existence.
        attr_reader :existence

        delegate_missing_to :@schema

        def initialize(schema, existence)
          @schema = schema
          @existence = existence
        end

        def inspect # :nodoc:
          "#<#{self.class.name} " \
          "schema: #{@schema.inspect}, " \
          "existence: #{@existence.inspect}>"
        end
      end
    end
  end
end
