# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class Dummy < BaseObject
      attr_reader :value

      delegate :empty?, to: :value

      def initialize(value, schema = nil)
        super(schema)
        @value = value
      end

      def null?
        @value.nil?
      end
    end
  end
end
