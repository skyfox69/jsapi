# frozen_string_literal: true

module Jsapi
  module Meta
    class ReferenceError < StandardError
      def initialize(reference)
        super("reference can't be resolved: '#{reference}'")
      end
    end
  end
end
