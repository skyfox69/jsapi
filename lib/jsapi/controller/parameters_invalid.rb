# frozen_string_literal: true

module Jsapi
  module Controller
    # Raised by Methods#api_operation! when the request parameters are invalid.
    class ParametersInvalid < StandardError

      # The parameters.
      attr_reader :params

      def initialize(params)
        @params = params
        super('')
      end

      # Returns the errors encountered.
      def errors
        @params.errors.errors
      end

      # Overrides <code>Exception#message</code> to lazily generate the error message.
      def message
        "#{@params.errors.full_messages.map { |m| m.delete_suffix('.') }.join('. ')}."
      end
    end
  end
end
