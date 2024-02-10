# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Decorator
        attr_reader :existence

        delegate_missing_to :@schema

        def initialize(schema, existence)
          @schema = schema
          @existence = existence
        end
      end
    end
  end
end
