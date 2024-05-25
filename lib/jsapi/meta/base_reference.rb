# frozen_string_literal: true

module Jsapi
  module Meta
    class BaseReference < Base
      ##
      # :attr: ref
      # The name of the referred object.
      attribute :ref, String

      # Returns the name of the method to be invoked to look up the referred
      # object in a Definitions instance.
      def self.lookup_method_name
        @lookup_method_name ||=
          name.delete_suffix('::Reference').demodulize.underscore
      end

      def reference? # :nodoc:
        true
      end

      # Resolves +ref+ by looking up the object with that name in +definitions+.
      #
      # Raises a ReferenceError if +ref+ could not be resolved.
      def resolve(definitions)
        object = definitions.send(self.class.lookup_method_name, ref)
        raise ReferenceError, ref if object.nil?

        object.resolve(definitions)
      end
    end
  end
end
