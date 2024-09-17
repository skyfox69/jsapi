# frozen_string_literal: true

module Jsapi
  module Meta
    module Base
      # The base reference class.
      class Reference < Model
        ##
        # :attr: ref
        # The name of the referred object.
        attribute :ref, String

        # Derrives the component type from the inner most module name.
        def self.component_type
          @component_type ||= name.split('::')[-2].underscore
        end

        # Returns true.
        def reference?
          true
        end

        # Resolves +ref+ by looking up the object with that name in +definitions+.
        #
        # Raises a ReferenceError if +ref+ could not be resolved.
        def resolve(definitions)
          object = definitions.find_component(self.class.component_type, ref)
          raise ReferenceError, ref if object.nil?

          object.resolve(definitions)
        end
      end
    end
  end
end
