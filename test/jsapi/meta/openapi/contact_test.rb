# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ContactTest < Minitest::Test
        def test_empty_contact_object
          assert_equal({}, Contact.new.to_openapi)
        end

        def test_full_contact_object
          assert_equal(
            {
              name: 'Foo',
              url: 'https://foo.bar',
              email: 'foo@foo.bar'
            },
            Contact.new(
              name: 'Foo',
              url: 'https://foo.bar',
              email: 'foo@foo.bar'
            ).to_openapi
          )
        end
      end
    end
  end
end
