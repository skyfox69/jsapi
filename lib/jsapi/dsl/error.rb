# frozen_string_literal: true

module Jsapi
  module DSL
    class Error < StandardError
      def initialize(error, origin = nil)
        @path = origin.present? ? [origin] : []
        super(error.message)
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
