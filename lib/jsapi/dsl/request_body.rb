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
    end
  end
end
