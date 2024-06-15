# frozen_string_literal: true

module Jsapi
  module Controller
    # Raised by Methods#api_operation! if the request parameters are invalid.
    class ParametersInvalid < StandardError
      attr_reader :params

      def initialize(params)
        @params = params
        super('')
      end

      # Overrides <code>StandardError#message</code> to lazily generate the error message.
      def message
        "#{
          @params.errors.full_messages.map do |message|
            message.delete_suffix('.')
          end.join('. ')
        }."
      end
    end
  end
end
