# frozen_string_literal: true

module Jsapi
  module Controller
    class Base < ActionController::API
      extend Dsl::ClassMethods
      include Methods
    end
  end
end
