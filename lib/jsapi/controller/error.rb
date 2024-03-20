# frozen_string_literal: true

module Jsapi
  module Controller
    # Used by +api_operation!+ to produce an error response.
    class Error
      attr_reader :status

      delegate :message, :to_s, to: :@exception

      def initialize(exception, status:)
        @exception = exception
        @status = status
      end
    end
  end
end
