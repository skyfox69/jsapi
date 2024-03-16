# frozen_string_literal: true

module Jsapi
  module Controller
    class NestedError
      attr_reader :status

      delegate :message, :to_s, to: :@exception

      def initialize(exception, status:)
        @exception = exception
        @status = status
      end
    end
  end
end
