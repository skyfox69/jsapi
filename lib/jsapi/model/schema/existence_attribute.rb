# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module ExistenceAttribute
        def existence
          @existence ||= Existence::ALLOW_OMITTED
        end

        def existence=(existence)
          @existence = Existence.from(existence)
        end
      end
    end
  end
end
