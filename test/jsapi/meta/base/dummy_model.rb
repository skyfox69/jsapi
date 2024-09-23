# frozen_string_literal: true

module Jsapi
  module Meta
    module Base
      class DummyModel < Model
        attr_reader :last_changed

        protected

        def attribute_changed(name)
          @last_changed = name
        end
      end
    end
  end
end
