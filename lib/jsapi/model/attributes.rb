# frozen_string_literal: true

module Jsapi
  module Model
    module Attributes
      def self.included(mod)
        mod.delegate :[], :additional_attributes, :attribute?, :attributes, to: :nested
      end

      def method_missing(*args) # :nodoc:
        name = args.first.to_s
        _attr_readers.key?(name) ? _attr_readers[name] : super
      end

      def respond_to_missing?(param1, _param2) # :nodoc:
        _attr_readers.key?(param1.to_s) ? true : super
      end

      private

      def _attr_readers
        @_attr_readers ||= attributes.transform_keys(&:underscore)
      end
    end
  end
end
