# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define a parameter.
    class Parameter < Schema
      include OpenAPI::Examples

      ##
      # :method: deprecated
      # :args: arg
      # Specifies whether or not the parameter is deprecated.
      #
      #   deprecated true

      ##
      # :method: description
      # :args: arg
      # Specifies the description of the parameter.

      ##
      # :method: in
      # :args: location
      # Specifies the location of the parameter.
      #
      # See Meta::Parameter::Model#in for further information.
    end
  end
end
