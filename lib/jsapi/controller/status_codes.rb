# frozen_string_literal: true

module Jsapi
  module Controller
    class StatusCodes
      attr_reader :default, :invalid

      def initialize(**options)
        @default = options[:default]
        @invalid = options[:invalid]
      end
    end
  end
end
