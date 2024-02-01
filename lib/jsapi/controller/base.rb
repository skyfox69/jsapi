# frozen_string_literal: true

module Jsapi
  module Controller
    # The base API controller.
    class Base < ActionController::API
      include DSL
      include Methods
    end
  end
end
