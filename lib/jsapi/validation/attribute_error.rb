# frozen_string_literal: true

module Jsapi
  module Validation
    class AttributeError
      def initialize(name, error)
        @name = name
        @error = error
      end

      def message
        "#{@name} #{@error.message}" if @error&.message.present?
      end
    end
  end
end
