# frozen_string_literal: true

module Jsapi
  module DSL
    class Error < StandardError
      attr_reader :path

      def initialize(error, name = nil)
        @path = [name].compact
        super(error.message)
      end

      def message
        message = super
        return message if path.blank?

        "#{message} (at #{path.join('/')})"
      end
    end
  end
end
