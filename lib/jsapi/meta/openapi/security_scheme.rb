# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a security scheme object.
      class SecurityScheme < Object
        FLOWS = %i[authorizationCode clientCredentials implicit password].freeze
        LOCATIONS = %w[cookie header query].freeze
        TYPES = %w[apiKey basic http oauth2 openIdConnect].freeze

        attr_accessor :bearer_format, :description, :location, :name, :open_id_connect_url, :scheme
        attr_reader :type, :oauth_flows

        # TODO: validates :location, :name, presence: true, if: :api_key?
        # TODO: validates :scheme, presence: true, if: :http?
        # TODO: validates :open_id_connect_url, if :open_id_connect

        def add_oauth_flow(flow, keywords = {})
          key = flow.to_s.camelize(:lower).to_sym
          raise ArgumentError, "invalid flow: #{flow.inspect}" unless key.in?(FLOWS)

          (@oauth_flows ||= {})[key] = OAuthFlow.new(**keywords)
        end

        def in=(location)
          unless location.in?(LOCATIONS)
            raise ArgumentError, "invalid location: #{location.inspect}"
          end

          @location = location
        end

        def type=(type)
          normalized_type = type.to_s.camelize(:lower)
          unless normalized_type.in?(TYPES)
            raise ArgumentError, "invalid type: #{type.inspect}"
          end

          @normalized_type = normalized_type
          @type = type
        end

        def to_h(version)
          case @normalized_type
          when 'apiKey'
            { type: 'apiKey', name: name, in: location }
          when 'basic'
            if version.major == 2
              { type: 'basic' }
            else
              { type: 'http', scheme: 'basic' }
            end
          when 'http'
            if version.major == 2
              { type: 'basic' } if scheme == 'basic'
            else
              { type: 'http', scheme: scheme }.tap do |h|
                if scheme == 'bearer' && bearer_format.present?
                  h[:bearerFormat] = bearer_format.to_s
                end
              end
            end
          when 'oauth2'
            { type: 'oauth2' }.tap do |h|
              if oauth_flows&.any?
                if version.major == 2
                  key, oauth_flow = oauth_flows.first
                  h[:flow] = key.to_s
                  h.merge!(oauth_flow.to_h(version))
                else
                  h[:flows] = oauth_flows.transform_values do |flow|
                    flow.to_h(version)
                  end
                end
              end
            end
          when 'openIdConnect'
            {
              type: 'openIdConnect',
              openIdConnectUrl: open_id_connect_url&.to_s
            } unless version.major == 2
          else
            raise "invalid type: #{type.inspect}"
          end&.merge(description: description&.to_s)&.compact
        end
      end
    end
  end
end
