# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a request body.
    class RequestBody < Schema
      include Examples

      ##
      # :method: deprecated
      # :args: arg
      # Specifies whether or not the request body is deprecated.
      #
      #   deprecated true

      ##
      # :method: description
      # :args: arg
      # Specifies the description of the request body.

      ##
      # :method: ref
      # :args: name
      # Specifies the name of the reusable request body to be referred.

      ##
      # :method: schema
      # :args: name
      # Specifies the name of the reusable schema to be referred.
    end
  end
end
