# frozen_string_literal: true

module Jsapi
  module DSL
    # Raised if an error occurred when defining an API component.
    class Error < StandardError
      # Creates a new error. +origin+ is the innermost position at where
      # the error occurred.
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

      # Overrides StandardError#message to append the whole path of the
      # position at where the error occurred to the message, for example:
      # <tt>{message} (at foo/bar)</tt>.
      def message
        message = super
        return message if @path.empty?

        "#{message} (at #{@path.join('/')})"
      end

      # Prepends +origin+ to the path at where the error occurred.
      def prepend_origin(origin)
        @path.prepend(origin) if origin.present?
        self
      end
    end
  end
end
