# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Extensions
        def self.included(base) # :nodoc:
          base.attribute :openapi_extensions, { String => String }
        end

        private

        def with_openapi_extensions(keywords = {})
          keywords.merge!(
            openapi_extensions.transform_keys do |key|
              "x-#{key}".to_sym
            end
          ) if openapi_extensions.present?

          keywords.compact!
          keywords
        end
      end
    end
  end
end
