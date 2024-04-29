# frozen_string_literal: true

module Jsapi
  module Meta
    class InvalidArgumentError < ArgumentError
      def initialize(name, value, values)
        super("#{name} must be one of #{values.inspect}, is #{value.inspect}")
      end
    end
  end
end
