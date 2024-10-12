# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class HeaderTest < Minitest::Test
      def test_new_header
        header = Header.new
        assert_kind_of(Header::Model, header)
      end

      def test_new_reference
        header = Header.new(ref: 'foo')
        assert_kind_of(Header::Reference, header)
      end
    end
  end
end
