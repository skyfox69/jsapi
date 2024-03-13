# frozen_string_literal: true

module Jsapi
  module Model
    module Validations
      extend ActiveSupport::Concern

      include ActiveModel::Validations

      included do
        validate :nested_validity
      end

      # Overrides +ActiveModel::Validations#errors+.
      def errors
        @errors ||= Errors.new(self)
      end

      private

      def nested_validity
        nested.validate(errors)
      end
    end
  end
end
