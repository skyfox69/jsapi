# frozen_string_literal: true

module Jsapi
  module Meta
    module SecurityScheme
      class Base < Meta::Base::Model
        ##
        # :attr: description
        # The description of the security scheme.
        attribute :description, String
      end
    end
  end
end
