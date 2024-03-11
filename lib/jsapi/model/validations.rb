# frozen_string_literal: true

module Jsapi
  module Model
    module Validations
      extend ActiveSupport::Concern

      include ActiveModel::Validations

      included do
        validate :nested_validity
      end

      def errors
        @errors ||= Errors.new
      end

      private

      def nested_validity
        nested.validate(errors)
      end
    end
  end
end
