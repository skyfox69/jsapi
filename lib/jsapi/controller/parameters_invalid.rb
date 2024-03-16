# frozen_string_literal: true

module Jsapi
  module Controller
    class ParametersInvalid < StandardError
      attr_reader :params

      def initialize(params)
        @params = params
        super('')
      end

      # Overrides +StandardError#message+ to lazily generate the message.
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
