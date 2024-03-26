# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      class Root < Node
        def to_h(version)
          version = OpenAPI::Version.from(version)
          if version.major == 2
            { swagger: '2.0' }
          else
            { openapi: version.minor.zero? ? '3.0.3' : '3.1.0' }
          end.merge(super())
        end
      end
    end
  end
end
