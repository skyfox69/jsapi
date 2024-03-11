# frozen_string_literal: true

module Jsapi
  module DSL
    class Error < StandardError
      def initialize(error_or_message, origin = nil)
        @path = origin.present? ? [origin] : []
        super(
          if error_or_message.respond_to?(:message)
            error_or_message.message
          else
            error_or_message
          end
        )
      end

      def message
        message = super
        return message if @path.blank?

        "#{message} (at #{@path.join('/')})"
      end

      def prepend_origin(origin)
        @path.prepend(origin) if origin.present?
        self
      end
    end
  end
end
