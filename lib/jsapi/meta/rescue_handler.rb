# frozen_string_literal: true

module Jsapi
  module Meta
    # Maps a +StandardError+ class to a response status.
    class RescueHandler
      # The response status.
      attr_reader :status

      # Creates a new rescue handler to map +klass+ to +status+. The default response status
      # is <code>"default"</code>.
      #
      # Raises an +ArgumentError+ if +klass+ isn't a +StandardError+ class.
      def initialize(klass, status: nil)
        unless klass.is_a?(Class) && klass.ancestors.include?(StandardError)
          raise ArgumentError, "#{klass.inspect} must be a standard error class"
        end

        @klass = klass
        @status = status || 'default'
      end

      def inspect # :nodoc:
        "#<#{self.class.name} class: #{@klass}, status: #{@status.inspect}>"
      end

      # Returns true if +exception+ is an instance of the class to be mapped, false otherwise.
      def match?(exception)
        exception.is_a?(@klass)
      end
    end
  end
end
