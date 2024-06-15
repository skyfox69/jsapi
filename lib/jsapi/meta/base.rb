# frozen_string_literal: true

module Jsapi
  module Meta
    # The base meta model class.
    class Base
      extend Attributes::ClassMethods

      # Creates a new meta model.
      #
      # Raises an +ArgumentError+ if at least one keyword is not supported.
      def initialize(keywords = {})
        keywords.each do |key, value|
          if respond_to?(method = "#{key}=")
            public_send(method, value)
          else
            raise ArgumentError, "unsupported keyword: #{key}"
          end
        end
      end

      def inspect # :nodoc:
        klass = self.class
        "#<#{klass.name} #{
          klass.attribute_names.map do |name|
            "#{name}: #{send(name).inspect}"
          end.join(', ')
        }>"
      end

      # Returns true if and only if this is a reference.
      def reference?
        false
      end

      # Returns itself.
      def resolve(*)
        self
      end
    end
  end
end
