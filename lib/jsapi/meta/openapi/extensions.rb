# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Extensions
        ##
        # :attr: openapi_extensions
        # The \OpenAPI extensions.

        # Adds an \OpenAPI extension.
        #
        # Raises an +ArgumentError+ if +name+ is blank.
        def add_openapi_extension(name, value = nil)
          raise ArgumentError, "name can't be blank" if name.blank?

          openapi_extensions["x-#{name}".to_sym] = value
        end

        def openapi_extensions # :nodoc:
          @openapi_extensions ||= {}
        end

        def openapi_extensions=(extensions) # :nodoc:
          @openapi_extensions = {}

          extensions.each do |name, value|
            add_openapi_extension(name, value)
          end
        end

        private

        def with_openapi_extensions(keywords = {}) # :nodoc:
          keywords.merge!(openapi_extensions)
          keywords.compact!
          keywords
        end
      end
    end
  end
end
