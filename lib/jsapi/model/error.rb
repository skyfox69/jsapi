# frozen_string_literal: true

module Jsapi
  module Model
    class Error < ActiveModel::Error

      # Overrides <code>ActiveModel::Error#full_message</code>.
      def full_message
        return message if attribute == :base || attribute.blank?

        "'#{attribute}' #{message}".rstrip
      end
    end
  end
end
