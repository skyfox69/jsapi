# frozen_string_literal: true

module Jsapi
  module Meta
    module Parameter
      class Reference < Meta::Base
        ##
        # :attr_reader: ref
        # The name of the referred parameter.
        attribute :ref, String

        # Resolves the reference by looking up the reusable parameter with
        # the given name in +definitions+.
        #
        # Raises a ReferenceError if the reference could not be resolved.
        def resolve(definitions)
          parameter = definitions.parameter(ref)
          raise ReferenceError, ref if parameter.nil?

          parameter
        end

        # Returns an array of hashes. Each element represents an \OpenAPI
        # parameter object if the type of the referred parameter is
        # <code>"object"</code>. Otherwise the array contains a single
        # hash representing the \OpenAPI reference object.
        #
        # Raises a ReferenceError if the reference could not be resolved.
        def to_openapi_parameters(version, definitions)
          version = OpenAPI::Version.from(version)
          parameter = resolve(definitions)

          if parameter.schema.resolve(definitions).object?
            # Explode referred parameter
            parameter.to_openapi_parameters(version, definitions)
          else
            # Return an array containing the reference object
            path = version.major == 2 ? 'parameters' : 'components/parameters'

            [{ '$ref': "#/#{path}/#{ref}" }]
          end
        end
      end
    end
  end
end
