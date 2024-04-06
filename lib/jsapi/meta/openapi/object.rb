# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      class Object
        def initialize(**keywords)
          keywords.each do |keyword, value|
            method = "#{keyword}="

            unless respond_to?(method)
              raise ArgumentError, "invalid keyword: #{keyword}"
            end

            send(method, value)
          end
        end
      end
    end
  end
end
