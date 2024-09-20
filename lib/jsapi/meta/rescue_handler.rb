# frozen_string_literal: true

module Jsapi
  module Meta
    # Maps an error class to a response status.
    class RescueHandler < Base::Model
      ##
      # :attr: error_class
      # The error class to be mapped.
      attribute :error_class, default: StandardError

      ##
      # :attr: status
      # The response status. The default is <code>"default"</code>.
      attribute :status, default: 'default'

      def initialize(keywords = {})
        super
        unless error_class.is_a?(Class)
          raise ArgumentError, "#{error_class.inspect} isn't a class"
        end
        unless error_class <= StandardError
          raise ArgumentError, "#{error_class.inspect} isn't a rescuable class"
        end
      end

      # Returns true if +exception+ is an instance of the class to be mapped, false otherwise.
      def match?(exception)
        exception.is_a?(error_class)
      end
    end
  end
end
