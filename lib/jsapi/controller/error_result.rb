# frozen_string_literal: true

module Jsapi
  module Controller
    # Used by Methods#api_operation! to produce an error response.
    class ErrorResult
      delegate_missing_to :@exception

      # The HTTP status code of the error response to be produced.
      attr_reader :status

      # Creates a new instance to produce an error response with the given HTTP status code.
      def initialize(exception, status: nil)
        @exception = exception
        @status = status
      end

      # Returns the string representation of the exception encountered to render this string
      # when the response type is +string+, for example:
      #
      #   response 500, type: 'string'
      def to_s
        @exception.to_s
      end
    end
  end
end
