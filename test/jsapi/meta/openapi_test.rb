# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class OpenAPITest < Minitest::Test
      def test_new
        assert_kind_of(OpenAPI::Root, OpenAPI.new)
      end
    end
  end
end
