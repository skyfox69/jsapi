# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a security requirement object.
      class SecurityRequirement < Object
        class Scheme < Object
          attr_accessor :scopes

          def initialize(**keywords)
            @scopes = []
            super
          end

          def add_scope(scope)
            raise ArgumentError, "scope can't be blank" if scope.blank?

            @scopes << scope.to_s
          end
        end

        attr_reader :schemes

        def initialize(**keywords)
          @schemes = {}
          super
        end

        def add_scheme(name, keywords = {})
          raise ArgumentError, "name can't be blank" if name.blank?

          @schemes[name.to_s] = Scheme.new(**keywords)
        end

        def to_h
          schemes.transform_values(&:scopes)
        end
      end
    end
  end
end
