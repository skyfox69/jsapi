# frozen_string_literal: true

module Jsapi
  module Controller
    class Base < ActionController::API
      include DSL
      include Methods
    end
  end
end
