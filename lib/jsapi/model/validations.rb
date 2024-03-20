# frozen_string_literal: true

module Jsapi
  module Model
    module Validations
      extend ActiveSupport::Concern

      include ActiveModel::Validations

      included do
        validate :nested_validity
      end

      # Overrides <tt>ActiveModel::Validations#errors</tt> to store errors in
      # an instance of <tt>Jsapi::Model::Errors</tt>.
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
