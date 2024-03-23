# frozen_string_literal: true

module Jsapi
  module Controller
    # Used by +api_operation!+ to produce an error response.
    class ErrorResult

      # The HTTP status code of the error response to be produced.
      attr_reader :status

      delegate :message, :to_s, to: :@exception

      # Creates a new instance to produce an error response with the given
      # HTTP status code.
      def initialize(exception, status:)
        @exception = exception
        @status = status
      end
    end
  end
end
