# frozen_string_literal: true

module Jsapi
  module Validation
    class AttributeError
      def initialize(name, error)
        @name = name
        @error = error
      end

      def message
        "#{@name} #{@error.message}"
      end
    end
  end
end
