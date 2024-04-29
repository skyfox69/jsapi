# frozen_string_literal: true

require_relative 'security_scheme/base'
require_relative 'security_scheme/api_key'
require_relative 'security_scheme/http'
require_relative 'security_scheme/oauth2'
require_relative 'security_scheme/open_id_connect'

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        class << self
          # Creates a security scheme. The +:type+ keyword specifies the type
          # of the security scheme to be created. Possible types are:
          #
          # - <code>"api_key"</code>
          # - <code>"basic"</code>
          # - <code>"http"</code>
          # - <code>"oauth2"</code>
          # - <code>"open_id_connect"</code>
          #
          # Raises an InvalidArgumentError if the given type is invalid.
          def new(keywords = {})
            type = keywords[:type]
            keywords = keywords.except(:type)

            case type&.to_s
            when 'api_key'
              APIKey.new(keywords)
            when 'basic' # OpenAPI 2.0
              HTTP.new(keywords.merge(scheme: 'basic'))
            when 'http' # OpenAPI 3.x
              HTTP.new(keywords)
            when 'oauth2'
              OAuth2.new(keywords)
            when 'open_id_connect' # OpenAPI 3.x
              OpenIDConnect.new(keywords)
            else
              raise InvalidArgumentError.new(
                'type',
                type,
                %w[api_key basic http oauth2 open_id_connect]
              )
            end
          end
        end
      end
    end
  end
end
