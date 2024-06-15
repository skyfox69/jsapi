# frozen_string_literal: true

module Jsapi
  module Model
    module Naming
      include ActiveModel::Naming
      include ActiveModel::Translation

      # Overrides <code>ActiveModel::Naming#model_name</code> to support anonymous
      # model classes.
      def model_name
        @_model_name ||= begin
          # Copied from ActiveModel::Naming#model_name
          namespace = module_parents.detect do |m|
            m.respond_to?(:use_relative_model_naming?) &&
              m.use_relative_model_naming?
          end
          # Prevent that ActiveModel::Name::new raises an error if this is an anonymous class
          klass = self
          klass = klass.superclass while klass.name.nil?

          ActiveModel::Name.new(klass, namespace)
        end
      end
    end
  end
end
