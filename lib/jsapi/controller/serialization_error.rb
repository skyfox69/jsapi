# frozen_string_literal: true

module Jsapi
  module Controller
    # Raised when an error occurred while serialization a response body.
    class SerializationError < RuntimeError

      # Overrides <code>RuntimeError#message</code> to prepend path.
      def message
        [@path&.delete_prefix('.') || 'response body', super].join(' ')
      end

      # Prepends +origin+ to the path at where the error occurred.
      def prepend(origin)
        @path = "#{origin}#{@path}"
        self
      end
    end
  end
end
