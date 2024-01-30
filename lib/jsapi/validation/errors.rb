# frozen_string_literal: true

module Jsapi
  module Validation
    class Errors < Array
      # Adds a new error of +type+. Default type is +:invalid+.
      def add(type = :invalid, **options)
        self << Error.new(type, **options)
      end

      # Error messages as a +String+.
      def full_message
        full_messages.join('. ')
      end

      # Error messages as an +Array+.
      def full_messages
        each.map { |error| error.message&.upcase_first }
      end
    end
  end
end
