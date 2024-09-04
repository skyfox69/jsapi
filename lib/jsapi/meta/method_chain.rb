# frozen_string_literal: true

module Jsapi
  module Meta
    class MethodChain
      # The methods to be called in chain.
      attr_reader :methods

      def initialize(methods)
        @methods = Array.wrap(methods).flat_map do |method|
          next method if method.is_a?(Symbol)

          method.to_s.split('.')
        end.map(&:to_sym)
      end

      def inspect # :nodoc:
        "#<#{self.class.name} #{methods.inspect}>"
      end

      # Calls the chained methods on +object+.
      def call(object, safe_send: false)
        return if methods.blank?

        methods.each do |method|
          return nil if safe_send && !object.respond_to?(method)

          object = object.public_send(method)
        end
        object
      end
    end
  end
end
