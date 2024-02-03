# frozen_string_literal: true

module Jsapi
  module Validation
    class Error
      attr_reader :type

      def initialize(type = :invalid, **options)
        @type = type
        @options = options
      end

      def message
        I18n.t(type, scope: 'errors.messages', **@options) if type.present?
      end
    end
  end
end
