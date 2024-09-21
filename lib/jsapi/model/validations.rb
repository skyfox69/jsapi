# frozen_string_literal: true

module Jsapi
  module Model
    module Validations
      def self.included(mod)
        mod.include ActiveModel::Validations
        mod.validate :nested_validity
      end

      # Overrides <code>ActiveModel::Validations#errors</code>
      # to use Errors as error store.
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
