# frozen_string_literal: true

module Jsapi
  module Controller
    class BadRequestError
      attr_reader :errors, :status

      def initialize(errors, status: 400)
        @errors = errors
        @status = status
      end

      def message
        @message ||= "#{
          @errors.full_messages.map do |message|
            message.delete_suffix('.')
          end.join('. ')
        }."
      end
    end
  end
end
