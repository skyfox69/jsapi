# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Extensions
        # Adds an \OpenAPI extension.
        #
        # Raises an +ArgumentError+ if +name+ is blank.
        def add_openapi_extension(name, value = nil)
          raise ArgumentError, "name can't be blank" if name.blank?

          openapi_extensions["x-#{name}".to_sym] = value
        end

        # Returns a hash containing the \OpenAPI extensions.
        def openapi_extensions
          @openapi_extensions ||= {}
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
