# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class RescueHandlerTest < Minitest::Test
      def test_match
        rescue_handler = RescueHandler.new

        assert(rescue_handler.match?(StandardError.new))
        assert(rescue_handler.match?(RuntimeError.new))

        assert(!rescue_handler.match?(Exception.new))
      end
    end
  end
end
