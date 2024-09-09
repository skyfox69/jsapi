# frozen_string_literal: true

module Jsapi
  module Meta
    # Holds the default values for a particular Schema type.
    class Defaults < Base::Model
      ##
      # :attr: read
      # The default value when reading requests.
      attribute :read, Object

      ##
      # :attr: write
      # The default value when writing responses.
      attribute :write, Object
    end
  end
end
