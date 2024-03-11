# frozen_string_literal: true

module Jsapi
  module Model
    class Error < ActiveModel::Error
      def full_message
        return message if attribute == :base || attribute.blank?

        "'#{attribute}' #{message}".rstrip
      end

      def message
        return type unless type.is_a?(Symbol)

        I18n.t(type, scope: 'errors.messages', **options)
      end
    end
  end
end
