# frozen_string_literal: true

module Jsapi
  module Model
    module Attributes
      extend ActiveSupport::Concern

      included do
        delegate :[], :attribute?, :attributes, to: :nested
      end

      def method_missing(*args)
        name = args.first
        attribute?(name) ? self[name] : super
      end

      def respond_to_missing?(param1, _param2)
        attribute?(param1) ? true : super
      end
    end
  end
end
