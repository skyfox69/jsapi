# frozen_string_literal: true

module Jsapi
  module Validation
    class Errors < Array
      # Adds a new error of +type+. Default type is +:invalid+.
      def add(type = :invalid, **options)
        self << Error.new(type, **options)
      end

      # The error messages as a +String+.
      def full_message
        full_messages.join('. ')
      end

      alias to_s full_message

      # The error messages as an +Array+.
      def full_messages
        each.filter_map { |error| error.message&.upcase_first }
      end

      def to_json(*)
        full_message
      end
    end
  end
end
