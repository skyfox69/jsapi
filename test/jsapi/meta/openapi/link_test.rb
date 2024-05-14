# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class LinkTest < Minitest::Test
        def test_new_model
          link = Link.new
          assert_kind_of(Link::Model, link)
        end

        def test_new_reference
          link = Link.new(ref: 'foo')
          assert_kind_of(Link::Reference, link)
        end
      end
    end
  end
end
