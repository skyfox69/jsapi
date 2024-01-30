# frozen_string_literal: true

module Jsapi
  module Model
    class ReferenceError < StandardError
      def initialize(reference)
        super("Reference can't be resolved: '#{reference}'")
      end
    end
  end
end
