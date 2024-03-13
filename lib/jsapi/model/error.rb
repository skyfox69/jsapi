# frozen_string_literal: true

module Jsapi
  module Model
    class Error < ActiveModel::Error
      def full_message
        return message if attribute == :base || attribute.blank?

        "'#{attribute}' #{message}".rstrip
      end
    end
  end
end
