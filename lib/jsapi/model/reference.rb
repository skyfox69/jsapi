# frozen_string_literal: true

module Jsapi
  module Model
    class Reference
      COMPONENTS = '#/components'

      attr_accessor :reference

      def initialize(reference)
        @reference = reference
      end
    end
  end
end
