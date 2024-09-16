# frozen_string_literal: true

module Jsapi
  module Meta
    # Maps an error class to a response status.
    class RescueHandler < Base::Model
      ##
      # :attr: error_class
      # The error class to be mapped.
      attribute :error_class, Class, default: StandardError

      ##
      # :attr: status
      # The response status. The default is <code>"default"</code>.
      attribute :status, default: 'default'

      # Returns true if +exception+ is an instance of the class to be mapped, false otherwise.
      def match?(exception)
        exception.is_a?(error_class)
      end
    end
  end
end
