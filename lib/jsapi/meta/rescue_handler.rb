# frozen_string_literal: true

module Jsapi
  module Meta
    class RescueHandler
      attr_reader :status

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

      def match?(exception)
        exception.is_a?(@klass)
      end
    end
  end
end
